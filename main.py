from fastapi.responses import StreamingResponse
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
import google.generativeai as genai
import requests

# 1. Cấu hình Gemini API
GOOGLE_API_KEY = "ghi ra so bi lo"
genai.configure(api_key=GOOGLE_API_KEY)

# Hàm tra từ điển Jisho (Vũ khí của AI)
def search_jisho(keyword: str) -> str:
    """Sử dụng công cụ này ĐỂ TRA CỨU từ vựng tiếng Nhật. 
    Nó sẽ trả về Kanji, cách đọc, nghĩa tiếng Anh và cấp độ JLPT."""
    url = f"https://jisho.org/api/v1/search/words?keyword={keyword}"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        if data.get("data"):
            first_result = data["data"][0]
            japanese_info = first_result["japanese"][0]
            kanji = japanese_info.get("word", keyword)
            reading = japanese_info.get("reading", "")
            english_meanings = ", ".join(first_result["senses"][0]["english_definitions"])
            jlpt_levels = first_result.get("jlpt", [])
            jlpt = jlpt_levels[0] if jlpt_levels else "Không xác định"
            return f"Kanji: {kanji} | Đọc: {reading} | Nghĩa: {english_meanings} | JLPT: {jlpt}"
    return f"Không tìm thấy dữ liệu cho từ '{keyword}' trong từ điển Jisho."

# 2. Khởi tạo Model (Hãy nhớ thay đổi tên model đúng với kết quả bạn test lúc nãy nhé)
model = genai.GenerativeModel(model_name='gemini-2.5-flash', tools=[search_jisho])

app = FastAPI(title="Japanese AI Tutor API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- PHẦN NÂNG CẤP TRÍ NHỚ BẮT ĐẦU TỪ ĐÂY ---

# 3. Định nghĩa cấu trúc của một tin nhắn cũ trong lịch sử chat
class Message(BaseModel):
    role: str # Ai gửi? ('user' là người dùng, 'model' là bot)
    content: str # Nội dung tin nhắn

# 4. Thêm biến 'history' vào gói dữ liệu gửi lên API
class ChatRequest(BaseModel):
    message: str
    context: str = ""
    history: List[Message] = [] # Mặc định là mảng rỗng nếu là tin nhắn đầu tiên

# --- API MỚI: DÀNH CHO HIỆU ỨNG GÕ CHỮ TỪ TỪ (STREAMING) ---
@app.post("/api/chat/stream")
async def chat_stream_with_ai(request: ChatRequest):
    # Nhắc nhở AI về nhiệm vụ (System Prompt tối ưu)
    system_instruction = (
        "Bạn là trợ lý AI chuyên môn về tiếng Nhật. Hãy trả lời trực tiếp, chính xác và đi thẳng vào trọng tâm. "
        "TUYỆT ĐỐI KHÔNG sử dụng các từ xưng hô kiểu thầy/trò, Sensei, em... Hãy dùng văn phong trung lập, khách quan. "
        "Quy tắc bắt buộc: Nếu người dùng hỏi từ vựng cụ thể, PHẢI dùng công cụ 'search_jisho'. "
        "Cấu trúc trả lời: Giải nghĩa -> Cách dùng -> Ví dụ (kèm Romaji và nghĩa tiếng Việt).\n"
        f"Ngữ cảnh trên web: {request.context}\n"
    )
    
    # Định dạng lại lịch sử chat
    gemini_history = []
    for msg in request.history:
        gemini_history.append({"role": msg.role, "parts": [msg.content]})

    # Tạo Session có trí nhớ và công cụ Jisho
    chat = model.start_chat(
        history=gemini_history,
    )
    
    full_message = f"[{system_instruction}]\nCâu hỏi: {request.message}"

    # HÀM PHÁT SÓNG: Cứ có chữ nào là ném về Frontend chữ đó
    async def generate_responses():
        try:
            # Gửi tin nhắn và bật chế độ stream=True
            response = chat.send_message(full_message, stream=True)
            
            for chunk in response:
                if chunk.text:
                    # Đóng gói từng chữ theo chuẩn Server-Sent Events (SSE)
                    yield f"data: {chunk.text}\n\n"
                    
        except Exception as e:
            yield f"data: [LỖI HỆ THỐNG]: {str(e)}\n\n"

    # Trả về một luồng dữ liệu liên tục thay vì một cục JSON tĩnh
    return StreamingResponse(generate_responses(), media_type="text/event-stream")