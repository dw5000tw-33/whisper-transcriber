import os
import sys
import shutil
import threading
import tempfile
import webbrowser
import tkinter as tk
from tkinter import filedialog, messagebox
from tkinter.scrolledtext import ScrolledText

import customtkinter as ctk
import whisper


# ===== 色彩設定 =====
MAIN_BLUE = "#1E3A8A"
LIGHT_BLUE = "#EAF2FF"
LIGHT_BLUE_HOVER = "#DCE8FF"
LINE_GREEN = "#22C55E"
LINE_GREEN_HOVER = "#16A34A"
TEXT_GRAY = "#64748B"
BORDER_GRAY = "#E2E8F0"


# ===== 基本路徑 =====
if getattr(sys, "frozen", False):
    BASE_DIR = os.path.dirname(sys.executable)
else:
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))


# ===== GitHub 公開版：使用系統 PATH =====
FFMPEG_BIN = "ffmpeg"
NODE_PATH = "node"


class WhisperGUI(ctk.CTk):
    def __init__(self):
        super().__init__()

        ctk.set_appearance_mode("light")
        ctk.set_default_color_theme("blue")

        self.title("Whisper語音轉文字")
        self.geometry("1150x780")
        self.minsize(1050, 700)

        self.model = None
        self.is_running = False
        self.loading_job = None
        self.loading_index = 0

        self.audio_path = tk.StringVar()
        self.output_path = tk.StringVar()
        self.download_dir = tk.StringVar()

        self.model_name = tk.StringVar()
        self.language = tk.StringVar()

        self.model_map = {
            "tiny - 快速": "tiny",
            "base - 基礎": "base",
            "small - 一般語音推薦": "small",
            "medium - 歌曲 / 背景音推薦": "medium",
            "large - 高準度但較慢": "large",
        }

        self.lang_map = {
            "自動偵測": "auto",
            "繁體中文": "zh",
            "英文": "en",
            "日文": "ja",
            "韓文": "ko",
        }

        self.model_name.set("small - 一般語音推薦")
        self.language.set("自動偵測")

        self.build_ui()

    # ================= UI =================
    def build_ui(self):
        self.grid_columnconfigure(0, weight=1)
        self.grid_rowconfigure(1, weight=1)

        # ===== Header =====
        header = ctk.CTkFrame(self, fg_color="white", corner_radius=14, border_width=1, border_color=BORDER_GRAY)
        header.grid(row=0, column=0, sticky="ew", padx=20, pady=(16, 8))
        header.grid_columnconfigure(1, weight=1)

        title_box = ctk.CTkFrame(header, fg_color="transparent")
        title_box.grid(row=0, column=0, padx=18, pady=14, sticky="w")

        ctk.CTkLabel(
            title_box,
            text="Whisper語音轉文字",
            font=("Microsoft JhengHei", 24, "bold"),
            text_color=MAIN_BLUE,
        ).pack(anchor="w")

        ctk.CTkLabel(
            title_box,
            text="音檔 / YouTube / 語音 → 自動轉成文字",
            font=("Microsoft JhengHei", 13),
            text_color=TEXT_GRAY,
        ).pack(anchor="w", pady=(4, 0))

        nav = ctk.CTkFrame(header, fg_color="transparent")
        nav.grid(row=0, column=1, padx=18, pady=14, sticky="e")

        ctk.CTkButton(
            nav,
            text="GitHub",
            width=120,
            height=38,
            fg_color=MAIN_BLUE,
            hover_color="#172F73",
            text_color="white",
            font=("Microsoft JhengHei", 14, "bold"),
            command=lambda: self.open_url("https://github.com/dw5000tw-33"),
        ).pack(side="left", padx=6)

        ctk.CTkButton(
            nav,
            text="LINE 官方",
            width=120,
            height=38,
            fg_color=LINE_GREEN,
            hover_color=LINE_GREEN_HOVER,
            text_color="white",
            font=("Microsoft JhengHei", 14, "bold"),
            command=lambda: self.open_url("https://line.me/R/ti/p/@307momvl"),
        ).pack(side="left", padx=6)

        # ===== Main =====
        main = ctk.CTkFrame(self, fg_color="white", corner_radius=16, border_width=1, border_color=BORDER_GRAY)
        main.grid(row=1, column=0, padx=20, pady=8, sticky="nsew")
        main.grid_columnconfigure(0, weight=1)
        main.grid_rowconfigure(6, weight=1)

        self.add_input_row(main, 0, "1. 音檔 / 網址", self.audio_path, "選擇", self.choose_audio)
        self.add_input_row(main, 1, "2. 輸出文字檔", self.output_path, "選擇", self.choose_output)
        self.add_input_row(main, 2, "3. 網路下載位置", self.download_dir, "選擇", self.choose_download_dir)

        # ===== 轉錄設定 =====
        setting = ctk.CTkFrame(main, fg_color="white", corner_radius=12, border_width=1, border_color=BORDER_GRAY)
        setting.grid(row=3, column=0, padx=18, pady=(8, 8), sticky="ew")
        setting.grid_columnconfigure((0, 1), weight=1)

        ctk.CTkLabel(
            setting,
            text="4. 轉錄設定",
            font=("Microsoft JhengHei", 15, "bold"),
            text_color="#0F172A",
        ).grid(row=0, column=0, columnspan=2, padx=14, pady=(12, 8), sticky="w")

        self.model_combo = ctk.CTkOptionMenu(
            setting,
            variable=self.model_name,
            values=list(self.model_map.keys()),
            height=40,
            fg_color=LIGHT_BLUE,
            button_color=LIGHT_BLUE,
            button_hover_color=LIGHT_BLUE_HOVER,
            text_color=MAIN_BLUE,
            dropdown_fg_color="white",
            dropdown_text_color="#0F172A",
        )
        self.model_combo.grid(row=1, column=0, padx=(14, 8), pady=(0, 14), sticky="ew")

        self.lang_combo = ctk.CTkOptionMenu(
            setting,
            variable=self.language,
            values=list(self.lang_map.keys()),
            height=40,
            fg_color=LIGHT_BLUE,
            button_color=LIGHT_BLUE,
            button_hover_color=LIGHT_BLUE_HOVER,
            text_color=MAIN_BLUE,
            dropdown_fg_color="white",
            dropdown_text_color="#0F172A",
        )
        self.lang_combo.grid(row=1, column=1, padx=(8, 14), pady=(0, 14), sticky="ew")

        # ===== Buttons =====
        btns = ctk.CTkFrame(main, fg_color="white")
        btns.grid(row=4, column=0, padx=18, pady=(8, 10), sticky="ew")
        btns.grid_columnconfigure((0, 1, 2), weight=1)

        self.start_btn = ctk.CTkButton(
            btns,
            text="▶ 開始轉錄",
            height=46,
            fg_color=MAIN_BLUE,
            hover_color="#172F73",
            text_color="white",
            font=("Microsoft JhengHei", 15, "bold"),
            command=self.start_transcribe,
        )
        self.start_btn.grid(row=0, column=0, padx=(0, 8), sticky="ew")

        ctk.CTkButton(
            btns,
            text="清空結果",
            height=46,
            fg_color=LIGHT_BLUE,
            hover_color=LIGHT_BLUE_HOVER,
            text_color=MAIN_BLUE,
            font=("Microsoft JhengHei", 15, "bold"),
            command=self.clear_text,
        ).grid(row=0, column=1, padx=8, sticky="ew")

        ctk.CTkButton(
            btns,
            text="另存文字",
            height=46,
            fg_color="white",
            hover_color="#F8FAFC",
            text_color=MAIN_BLUE,
            border_width=2,
            border_color=MAIN_BLUE,
            font=("Microsoft JhengHei", 15, "bold"),
            command=self.save_text_from_box,
        ).grid(row=0, column=2, padx=(8, 0), sticky="ew")

        # ===== Progress / Status =====
        progress_area = ctk.CTkFrame(main, fg_color=LIGHT_BLUE, corner_radius=12)
        progress_area.grid(row=5, column=0, padx=18, pady=(0, 12), sticky="ew")
        progress_area.grid_columnconfigure(1, weight=1)

        self.loading_label = ctk.CTkLabel(
            progress_area,
            text="●",
            text_color="#10B981",
            font=("Microsoft JhengHei", 18, "bold"),
        )
        self.loading_label.grid(row=0, column=0, padx=(14, 8), pady=10, sticky="w")

        self.status_label = ctk.CTkLabel(
            progress_area,
            text="狀態：準備完成",
            text_color=MAIN_BLUE,
            font=("Microsoft JhengHei", 14, "bold"),
        )
        self.status_label.grid(row=0, column=1, padx=4, pady=10, sticky="w")

        self.progress_bar = ctk.CTkProgressBar(
            progress_area,
            height=10,
            progress_color=MAIN_BLUE,
            fg_color="#DCE8FF",
        )
        self.progress_bar.grid(row=1, column=0, columnspan=2, padx=14, pady=(0, 12), sticky="ew")
        self.progress_bar.set(0)

        # ===== Result =====
        result_frame = ctk.CTkFrame(main, fg_color="white", corner_radius=12, border_width=1, border_color=BORDER_GRAY)
        result_frame.grid(row=6, column=0, padx=18, pady=(0, 18), sticky="nsew")
        result_frame.grid_columnconfigure(0, weight=1)
        result_frame.grid_rowconfigure(1, weight=1)

        ctk.CTkLabel(
            result_frame,
            text="轉錄結果",
            font=("Microsoft JhengHei", 16, "bold"),
            text_color=MAIN_BLUE,
        ).grid(row=0, column=0, padx=14, pady=(12, 8), sticky="w")

        self.text_box = ScrolledText(
            result_frame,
            wrap="word",
            font=("Microsoft JhengHei", 12),
            bg="white",
            fg="#0F172A",
            insertbackground="#0F172A",
            relief="flat",
            highlightbackground=BORDER_GRAY,
            highlightthickness=1,
        )
        self.text_box.grid(row=1, column=0, padx=14, pady=(0, 14), sticky="nsew")

        # ===== 支持區 =====
        support = ctk.CTkFrame(self, fg_color=LIGHT_BLUE, corner_radius=14, border_width=1, border_color="#DCE8FF")
        support.grid(row=2, column=0, sticky="ew", padx=20, pady=(0, 16))
        support.grid_columnconfigure(0, weight=1)

        ctk.CTkLabel(
            support,
            text="如果這個工具幫到你，可以支持開發者 ❤️",
            text_color=MAIN_BLUE,
            font=("Microsoft JhengHei", 14, "bold"),
        ).grid(row=0, column=0, padx=18, pady=12)

        ctk.CTkButton(
            support,
            text="街口支持",
            width=130,
            height=36,
            fg_color=LIGHT_BLUE,
            hover_color=LIGHT_BLUE_HOVER,
            text_color=MAIN_BLUE,
            border_width=1,
            border_color="#C7D8FF",
            font=("Microsoft JhengHei", 14, "bold"),
            command=lambda: self.open_url("https://dw5000tw-33.github.io/fbauto/your-badge.png"),
        ).grid(row=0, column=1, padx=18, pady=12, sticky="e")

    def add_input_row(self, parent, row, title, var, btn_text, command):
        frame = ctk.CTkFrame(parent, fg_color="white")
        frame.grid(row=row, column=0, padx=18, pady=(16 if row == 0 else 6, 6), sticky="ew")
        frame.grid_columnconfigure(0, weight=1)

        ctk.CTkLabel(
            frame,
            text=title,
            font=("Microsoft JhengHei", 15, "bold"),
            text_color="#0F172A",
        ).grid(row=0, column=0, columnspan=2, padx=0, pady=(0, 6), sticky="w")

        entry = ctk.CTkEntry(
            frame,
            textvariable=var,
            height=40,
            font=("Microsoft JhengHei", 13),
            fg_color="white",
            border_color="#CBD5E1",
            text_color="#0F172A",
        )
        entry.grid(row=1, column=0, padx=(0, 10), pady=(0, 2), sticky="ew")

        ctk.CTkButton(
            frame,
            text=btn_text,
            width=110,
            height=40,
            fg_color=LIGHT_BLUE,
            hover_color=LIGHT_BLUE_HOVER,
            text_color=MAIN_BLUE,
            font=("Microsoft JhengHei", 14, "bold"),
            command=command,
        ).grid(row=1, column=1, padx=(0, 0), pady=(0, 2))

    # ================= 工具方法 =================
    def open_url(self, url):
        webbrowser.open(url)

    def choose_audio(self):
        path = filedialog.askopenfilename(
            title="選擇音檔",
            filetypes=[
                ("音訊/影片檔", "*.m4a *.mp3 *.wav *.mp4 *.aac *.flac *.ogg *.wma *.webm"),
                ("所有檔案", "*.*"),
            ],
        )
        if path:
            self.audio_path.set(path)
            if not self.output_path.get():
                base = os.path.splitext(os.path.basename(path))[0] + ".txt"
                self.output_path.set(os.path.join(os.path.dirname(path), base))
            if not self.download_dir.get():
                self.download_dir.set(os.path.dirname(path))

    def choose_output(self):
        path = filedialog.asksaveasfilename(
            title="選擇輸出文字檔",
            defaultextension=".txt",
            filetypes=[("文字檔", "*.txt"), ("所有檔案", "*.*")],
        )
        if path:
            self.output_path.set(path)
            if not self.download_dir.get():
                self.download_dir.set(os.path.dirname(path))

    def choose_download_dir(self):
        path = filedialog.askdirectory(title="選擇網路音檔下載位置")
        if path:
            self.download_dir.set(path)

    def clear_text(self):
        self.text_box.delete("1.0", tk.END)
        self.set_status("狀態：已清空結果", 0)

    def save_text_from_box(self):
        text = self.text_box.get("1.0", tk.END).strip()
        if not text:
            messagebox.showwarning("提醒", "目前沒有可儲存的文字。")
            return

        path = self.output_path.get().strip()
        if not path:
            path = filedialog.asksaveasfilename(defaultextension=".txt")
            if not path:
                return
            self.output_path.set(path)

        with open(path, "w", encoding="utf-8") as f:
            f.write(text)

        self.set_status(f"狀態：已儲存 {path}", 1)
        messagebox.showinfo("完成", f"已儲存：\n{path}")

    def set_status(self, msg, progress=None):
        def update():
            self.status_label.configure(text=msg)
            if progress is not None:
                self.progress_bar.set(progress)

        self.after(0, update)

    def append_text(self, text):
        def update():
            self.text_box.insert(tk.END, text)
            self.text_box.see(tk.END)

        self.after(0, update)

    def replace_text(self, text):
        def update():
            self.text_box.delete("1.0", tk.END)
            self.text_box.insert(tk.END, text)
            self.text_box.see(tk.END)

        self.after(0, update)

    # ================= Loading 動畫 =================
    def start_loading(self):
        self.loading_index = 0
        self._animate_loading()

    def _animate_loading(self):
        if not self.is_running:
            self.loading_label.configure(text="●", text_color="#10B981")
            return

        frames = ["●", "● ●", "● ● ●", "● ●", "●"]
        self.loading_label.configure(text=frames[self.loading_index % len(frames)], text_color=MAIN_BLUE)
        self.loading_index += 1
        self.loading_job = self.after(350, self._animate_loading)

    def stop_loading(self):
        if self.loading_job:
            try:
                self.after_cancel(self.loading_job)
            except Exception:
                pass
            self.loading_job = None
        self.loading_label.configure(text="●", text_color="#10B981")

    # ================= Whisper 功能 =================
    def load_model_if_needed(self):
        selected = self.model_name.get()
        wanted = self.model_map.get(selected, "small")

        if self.model is None or getattr(self, "_loaded_model_name", None) != wanted:
            self.set_status(f"狀態：載入模型中：{selected}", 0.35)
            self.model = whisper.load_model(wanted)
            self._loaded_model_name = wanted

    def start_transcribe(self):
        if self.is_running:
            messagebox.showwarning("提醒", "目前正在轉錄中，請稍候。")
            return

        audio = self.audio_path.get().strip()
        output = self.output_path.get().strip()

        if not audio:
            messagebox.showwarning("提醒", "請先選擇音檔或貼上網址。")
            return

        if not audio.startswith("http") and not os.path.exists(audio):
            messagebox.showerror("錯誤", "找不到音檔路徑。")
            return

        if not output:
            messagebox.showwarning("提醒", "請先選擇輸出文字檔位置。")
            return

        ffmpeg_path = shutil.which(FFMPEG_BIN)
        if not ffmpeg_path:
            messagebox.showerror(
                "缺少 ffmpeg",
                "找不到 ffmpeg。\n\n請先安裝 ffmpeg，並確認 CMD 可執行：\nffmpeg -version"
            )
            return

        self.ffmpeg_path = ffmpeg_path

        if audio.startswith("http"):
            node_path = shutil.which(NODE_PATH)
            if not node_path:
                messagebox.showerror(
                    "缺少 Node.js",
                    "找不到 Node.js。\n\n請先安裝 Node.js，並確認 CMD 可執行：\nnode -v"
                )
                return
            self.node_path = node_path

        self.is_running = True
        self.start_btn.configure(state="disabled", text="轉錄中...")
        self.progress_bar.set(0.05)
        self.replace_text("")
        self.set_status("狀態：開始處理...", 0.08)
        self.start_loading()

        threading.Thread(target=self._transcribe_worker, daemon=True).start()

    def _download_if_url(self, audio):
        if not audio.startswith("http"):
            return audio

        self.set_status("狀態：下載音訊中...", 0.18)

        import yt_dlp

        download_dir = self.download_dir.get().strip()
        if not download_dir:
            download_dir = os.path.dirname(self.output_path.get().strip()) or tempfile.gettempdir()

        os.makedirs(download_dir, exist_ok=True)

        output_template = os.path.join(download_dir, "audio.%(ext)s")

        ydl_opts = {
            "format": "bestaudio/best",
            "outtmpl": output_template,
            "noplaylist": True,
            "continuedl": True,
            "quiet": False,
            "ffmpeg_location": self.ffmpeg_path,
            "js_runtimes": {
                "node": {
                    "path": self.node_path
                }
            },
            "postprocessors": [
                {
                    "key": "FFmpegExtractAudio",
                    "preferredcodec": "m4a",
                    "preferredquality": "192",
                }
            ],
        }

        try:
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                info = ydl.extract_info(audio, download=True)
                before_convert = ydl.prepare_filename(info)

            final_audio = os.path.splitext(before_convert)[0] + ".m4a"

            if os.path.exists(final_audio):
                self.set_status("狀態：音訊下載完成", 0.28)
                return final_audio

            raise Exception(f"下載後找不到音檔：{final_audio}")

        except Exception as download_error:
            possible_files = []
            for filename in os.listdir(download_dir):
                if filename.startswith("audio") and filename.lower().endswith(
                    (".m4a", ".mp3", ".webm", ".opus", ".wav")
                ):
                    possible_files.append(os.path.join(download_dir, filename))

            if possible_files:
                fallback = max(possible_files, key=os.path.getsize)
                self.set_status(f"狀態：下載不完整，嘗試分析已下載片段", 0.25)
                return fallback

            raise Exception(f"下載失敗，沒有可分析音檔。\n\n原因：{download_error}")

    def _format_segments_live(self, result):
        lines = []
        current = ""

        segments = result.get("segments", [])
        total = max(len(segments), 1)

        for index, seg in enumerate(segments):
            t = seg.get("text", "").strip()
            if not t:
                continue

            current += " " + t

            if t.endswith(("。", "！", "？", ".", "!", "?")) or len(current) > 48:
                line = current.strip()
                lines.append(line)
                self.append_text(line + "\n")
                current = ""

            progress = 0.65 + (index + 1) / total * 0.22
            self.set_status(f"狀態：整理文字中 {index + 1}/{total}", progress)

        if current:
            line = current.strip()
            lines.append(line)
            self.append_text(line + "\n")

        return "\n".join(lines).strip()

    def _transcribe_worker(self):
        try:
            audio = self.audio_path.get().strip()
            output = self.output_path.get().strip()

            audio = self._download_if_url(audio)

            self.load_model_if_needed()

            lang_selected = self.language.get().strip()
            lang = self.lang_map.get(lang_selected, "auto")

            kwargs = {}
            if lang != "auto":
                kwargs["language"] = lang

            self.set_status("狀態：Whisper 轉錄中，請稍候...", 0.55)

            result = self.model.transcribe(audio, **kwargs)

            self.set_status("狀態：轉錄完成，開始整理文字...", 0.65)

            self.replace_text("")
            text = self._format_segments_live(result)

            if not text:
                text = result.get("text", "").strip()
                self.replace_text(text if text else "[沒有辨識到文字]")

            self.set_status("狀態：儲存文字檔中...", 0.93)

            with open(output, "w", encoding="utf-8") as f:
                f.write(text)

            self.set_status(f"狀態：完成，已輸出：{output}", 1)
            self.after(0, lambda: messagebox.showinfo("完成", f"轉錄完成\n已儲存到：\n{output}"))

        except Exception as e:
            error_msg = str(e)
            self.set_status("狀態：轉錄失敗", 0)
            self.after(0, lambda msg=error_msg: messagebox.showerror("錯誤", msg))

        finally:
            self.is_running = False
            self.after(0, self.stop_loading)
            self.after(0, lambda: self.start_btn.configure(state="normal", text="▶ 開始轉錄"))


if __name__ == "__main__":
    app = WhisperGUI()
    app.mainloop()
