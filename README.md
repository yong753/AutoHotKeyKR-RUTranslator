# Kakao Translator

KakaoTalk PC input translator using AutoHotkey v2, Python, and OpenRouter.

## Files

- `translate.py`: Calls OpenRouter and prints translated text.
- `kakao_translate.ahk`: Hotkeys for replacing the focused input text.

## Requirements

- Python 3.11+
- AutoHotkey v2
- OpenRouter API key in `OPENROUTER_API_KEY`

Install Python dependency:

```powershell
python -m pip install requests
```

Set API key:

```powershell
setx OPENROUTER_API_KEY "your_openrouter_api_key"
```

Open a new terminal after `setx`, then verify:

```powershell
echo $env:OPENROUTER_API_KEY
```

Optional model override:

```powershell
setx OPENROUTER_MODEL "deepseek/deepseek-v4-flash"
```

## Python Test

Korean to Russian:

```powershell
'오늘 저녁에 시간 괜찮으세요?' | python .\translate.py ko-ru
```

Russian to Korean:

```powershell
'Как дела?' | python .\translate.py ru-ko
```

## AutoHotkey Usage

1. Install AutoHotkey v2 from `https://www.autohotkey.com/`.
2. Run `kakao_translate.ahk` from the project folder.
3. Put the cursor in the KakaoTalk message input box.
4. Type a message.
5. Press `F4` for Korean to Russian, or `Shift+F4` for Russian to Korean.
6. Press `Enter` manually to send.

## Hotkeys

- `F4`: Korean to Russian
- `Shift+F4`: Russian to Korean

## Notes

- The hotkeys are active only when the KakaoTalk PC window is focused.
- It uses `Ctrl+A`, `Ctrl+C`, and `Ctrl+V`, so keep focus in the intended input box.
- The AutoHotkey script asks Python to write UTF-8 output directly to avoid Windows console encoding issues.
- The clipboard is restored after the translated text is pasted.
- Automatic sending with `Ctrl+Enter` should be added only after manual replacement is stable.
