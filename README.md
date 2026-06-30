# Kakao Translator

AutoHotkey v2, Python, OpenRouter를 사용한 카카오톡 PC 입력 번역기입니다.

## 파일 구성

- `translate.py`: OpenRouter API를 호출하여 번역된 텍스트를 출력합니다.
- `kakao_translate.ahk`: 포커스된 입력 텍스트를 교체하는 단축키를 제공합니다.

## 요구 사항

- Python 3.11+
- AutoHotkey v2
- `OPENROUTER_API_KEY` 환경 변수에 설정된 OpenRouter API 키

Python 의존성 설치:

```powershell
python -m pip install requests
```

API 키 설정:

```powershell
setx OPENROUTER_API_KEY "your_openrouter_api_key"
```

`setx` 실행 후 새 터미널을 열고 아래 명령어로 확인합니다:

```powershell
echo $env:OPENROUTER_API_KEY
```

선택적 모델 변경:

```powershell
setx OPENROUTER_MODEL "deepseek/deepseek-v4-flash"
```

## Python 테스트

한국어 → 러시아어:

```powershell
'오늘 저녁에 시간 괜찮으세요?' | python .\translate.py ko-ru
```

러시아어 → 한국어:

```powershell
'Как дела?' | python .\translate.py ru-ko
```

## AutoHotkey 사용법

1. `https://www.autohotkey.com/` 에서 AutoHotkey v2를 설치합니다.
2. 프로젝트 폴더에서 `kakao_translate.ahk`를 실행합니다.
3. 카카오톡 메시지 입력창에 커서를 놓습니다.
4. 메시지를 입력합니다.
5. `F4`(한국어→러시아어) 또는 `Shift+F4`(러시아어→한국어)를 누릅니다.
6. `Enter`를 직접 눌러 전송합니다.

## 단축키

- `F4`: 한국어 → 러시아어
- `Shift+F4`: 러시아어 → 한국어

## 참고 사항

- 카카오톡뿐만 아니라 현재 포커스된 모든 텍스트 입력창에서 동작합니다.
- `Ctrl+A`, `Ctrl+C`, `Ctrl+V`를 사용하므로 의도한 입력창에 포커스가 있는지 확인하세요.
- AutoHotkey 스크립트는 Windows 콘솔 인코딩 문제를 피하기 위해 Python이 UTF-8을 직접 출력하도록 요청합니다.
- 번역된 텍스트가 붙여넣어진 후 클립보드는 원래 내용으로 복원됩니다.
- `Ctrl+Enter`를 이용한 자동 전송은 수동 교체가 안정화된 후에 추가해야 합니다.

## 시작 프로그램에 등록 (자동 실행)

컴퓨터를 켤 때마다 AutoHotkey 스크립트가 자동으로 실행되도록 하려면 시작 프로그램에 등록하세요.

**방법 1 — 시작 프로그램 폴더에 바로가기 추가 (권장)**

1. `Win + R`을 누르고 `shell:startup`을 입력한 후 Enter를 누릅니다.
2. 열린 폴더에 `kakao_translate.ahk`의 바로가기를 만듭니다.
   - 프로젝트 폴더에서 `kakao_translate.ahk`를 마우스 오른쪽 버튼으로 클릭 → **바로가기 만들기**
   - 생성된 바로가기를 `shell:startup` 폴더로 이동합니다.

**방법 2 — 직접 명령어로 등록**

관리자 PowerShell에서 다음을 실행합니다:

```powershell
$shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\KakaoTranslator.lnk")
$shortcut.TargetPath = "C:\#경로#\kakao_translate.ahk"
$shortcut.WorkingDirectory = "C:\#경로"
$shortcut.Save()
```

위 `#경로#` 부분을 실제 `kakao_translate.ahk`가 있는 폴더 경로로 바꾸세요.

이제 윈도우 로그인 시 자동으로 AutoHotkey 스크립트가 실행되어 번역 단축키를 바로 사용할 수 있습니다.