import argparse
import os
import sys

import requests


OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"
DEFAULT_MODEL = "deepseek/deepseek-v4-flash"


def read_input(args: argparse.Namespace) -> str:
    if args.text:
        return args.text.strip()

    if args.file:
        with open(args.file, "r", encoding="utf-8") as file:
            return file.read().strip()

    return sys.stdin.read().strip()


def build_prompt(direction: str, text: str) -> str:
    if direction == "ko-ru":
        return "Translate this Korean text into natural Russian. Return only the translated text.\n\n" + text
    if direction == "ru-ko":
        return "Translate this Russian text into natural Korean. Return only the translated text.\n\n" + text
    raise ValueError(f"Unsupported direction: {direction}")


def translate(text: str, direction: str) -> str:
    api_key = os.environ.get("OPENROUTER_API_KEY")
    if not api_key:
        raise RuntimeError("OPENROUTER_API_KEY environment variable is not set.")

    model = os.environ.get("OPENROUTER_MODEL", DEFAULT_MODEL)
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://local.kakao-translator",
        "X-Title": "Kakao Translator",
    }
    payload = {
        "model": model,
        "messages": [
            {
                "role": "system",
                "content": (
                    "You are a translation engine for chat messages. "
                    "Do not explain, add notes, quote the result, or include alternatives. "
                    "Preserve line breaks when useful. Return only the final translated text."
                ),
            },
            {"role": "user", "content": build_prompt(direction, text)},
        ],
        "temperature": 0.1,
    }

    response = requests.post(OPENROUTER_URL, headers=headers, json=payload, timeout=60)
    if response.status_code >= 400:
        raise RuntimeError(f"OpenRouter API error {response.status_code}: {response.text}")

    data = response.json()
    try:
        result = data["choices"][0]["message"]["content"].strip()
    except (KeyError, IndexError, TypeError) as exc:
        raise RuntimeError(f"Unexpected OpenRouter response: {data}") from exc

    if not result:
        raise RuntimeError("OpenRouter returned an empty translation.")
    return result


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Translate text through OpenRouter.")
    parser.add_argument("direction", choices=["ko-ru", "ru-ko"], help="Translation direction")
    parser.add_argument("text", nargs="?", help="Text to translate. If omitted, stdin is used.")
    parser.add_argument("--file", help="Read text from a UTF-8 file instead of stdin")
    parser.add_argument("--output", help="Write translated text to a UTF-8 file instead of stdout")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    text = read_input(args)
    if not text:
        print("No input text.", file=sys.stderr)
        return 2

    try:
        result = translate(text, args.direction)
        if args.output:
            with open(args.output, "w", encoding="utf-8", newline="") as file:
                file.write(result)
        else:
            print(result)
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
