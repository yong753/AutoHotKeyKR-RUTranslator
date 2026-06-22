#Requires AutoHotkey v2.0
#SingleInstance Force

scriptDir := A_ScriptDir
pythonExe := "python"
translateScript := scriptDir "\translate.py"

F4::TranslateFocusedInput("ko-ru")
+F4::TranslateFocusedInput("ru-ko")

TranslateFocusedInput(direction) {
    global pythonExe, translateScript

    if !FileExist(translateScript) {
        MsgBox("translate.py not found:`n" translateScript, "Kakao Translator", "Iconx")
        return
    }

    EnsureEnvFromRegistry("OPENROUTER_API_KEY")
    EnsureEnvFromRegistry("OPENROUTER_MODEL")

    oldClipboard := ClipboardAll()
    A_Clipboard := ""

    Send("^a")
    Sleep(80)
    Send("^c")

    if !ClipWait(1) {
        RestoreClipboard(oldClipboard)
        MsgBox("Could not copy text from the focused input.", "Kakao Translator", "Iconx")
        return
    }

    sourceText := Trim(A_Clipboard, " `t`r`n")
    if sourceText = "" {
        RestoreClipboard(oldClipboard)
        return
    }

    tempInput := A_Temp "\kakao_translate_input_" A_TickCount ".txt"
    tempOutput := A_Temp "\kakao_translate_output_" A_TickCount ".txt"
    tempError := A_Temp "\kakao_translate_error_" A_TickCount ".txt"

    try {
        FileAppend(sourceText, tempInput, "UTF-8")
        command := Format(
            'cmd /c ""{}" "{}" {} --file "{}" --output "{}" 2> "{}""',
            pythonExe,
            translateScript,
            direction,
            tempInput,
            tempOutput,
            tempError
        )

        exitCode := RunWait(command, , "Hide")
        if exitCode != 0 {
            errorText := ReadFileIfExists(tempError)
            RestoreClipboard(oldClipboard)
            MsgBox("Translation failed:`n" errorText, "Kakao Translator", "Iconx")
            return
        }

        translatedText := Trim(ReadFileIfExists(tempOutput), " `t`r`n")
        if translatedText = "" {
            RestoreClipboard(oldClipboard)
            MsgBox("Translation result is empty.", "Kakao Translator", "Iconx")
            return
        }

        A_Clipboard := translatedText
        if !ClipWait(1) {
            RestoreClipboard(oldClipboard)
            MsgBox("Could not place translated text on clipboard.", "Kakao Translator", "Iconx")
            return
        }

        Send("^v")
        Sleep(80)
        RestoreClipboard(oldClipboard)
    } finally {
        DeleteFileIfExists(tempInput)
        DeleteFileIfExists(tempOutput)
        DeleteFileIfExists(tempError)
    }
}

ReadFileIfExists(path) {
    if !FileExist(path) {
        return ""
    }
    return FileRead(path, "UTF-8")
}

DeleteFileIfExists(path) {
    if FileExist(path) {
        FileDelete(path)
    }
}

RestoreClipboard(savedClipboard) {
    A_Clipboard := savedClipboard
}

EnsureEnvFromRegistry(name) {
    if EnvGet(name) != "" {
        return
    }

    try {
        value := RegRead("HKEY_CURRENT_USER\Environment", name)
        if value != "" {
            EnvSet(name, value)
        }
    }
}
