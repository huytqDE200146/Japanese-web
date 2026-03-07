from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from typing import List
import google.generativeai as genai
import requests

# 1. Cấu hình Gemini API
# LƯU Ý: Thay bằng API Key MỚI của bạn (đừng dùng cái cũ đã lộ)
GOOGLE_API_KEY = "your_api_key"
genai.configure(api_key=GOOGLE_API_KEY)

# 2. Khởi tạo FastAPI (CHỈ KHỞI TẠO 1 LẦN DUY NHẤT Ở ĐÂY)
app = FastAPI(title="Japanese AI Tutor API")

# 3. Cấu hình CORS (Cho phép mọi người kết nối)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 4. Cấu hình Model AI
# Lưu ý: Hiện tại bản ổn định là 'gemini-1.5-flash' hoặc 'gemini-2.0-flash-exp'
# 'gemini-2.5-flash' có thể chưa tồn tại hoặc bạn gõ nhầm. Mình để về 1.5 cho an toàn nhé.
model = genai.GenerativeModel(model_name='gemini-2.5-flash')

# --- CẤU TRÚC DỮ LIỆU ---
class Message(BaseModel):
    role: str 
    content: str 

class ChatRequest(BaseModel):
    message: str
    context: str = ""
    history: List[Message] = []

# --- API STREAMING (GÕ CHỮ TỪ TỪ) ---
@app.post("/api/chat/stream")
async def chat_stream_with_ai(request: ChatRequest):
    # Prompt (Chỉ dẫn hệ thống)
    system_instruction = (
        "Bạn là trợ lý AI chuyên môn về tiếng Nhật. Hãy trả lời trực tiếp, ngắn gọn. "
        "TUYỆT ĐỐI KHÔNG xưng hô thầy trò. "
        "Nếu người dùng hỏi từ vựng, hãy tự giải thích nghĩa, cách dùng và ví dụ (dùng kiến thức của bạn). "
        f"Ngữ cảnh: {request.context}\n"
    )
    
    # Xử lý lịch sử chat
    gemini_history = []
    for msg in request.history:
        gemini_history.append({"role": msg.role, "parts": [msg.content]})

    # Bắt đầu đoạn chat (Lưu ý: Đã bỏ tools Jisho để Streaming chạy mượt)
    chat = model.start_chat(history=gemini_history)
    
    full_message = f"[{system_instruction}]\nCâu hỏi: {request.message}"

    # Hàm sinh chữ (Generator)
    async def generate_responses():
        try:
            # stream=True giúp trả về từng mảnh dữ liệu
            response = chat.send_message(full_message, stream=True)
            for chunk in response:
                if chunk.text:
                    # Định dạng chuẩn SSE (Server-Sent Events)
                    yield f"data: {chunk.text}\n\n"
        except Exception as e:
            yield f"data: [LỖI]: {str(e)}\n\n"

    return StreamingResponse(generate_responses(), media_type="text/event-stream")

# --- API KIỂM TRA SERVER ---
@app.get("/")
async def root():
    return {"status": "Server đang chạy ngon lành!"}