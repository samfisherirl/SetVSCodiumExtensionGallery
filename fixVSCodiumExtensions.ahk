#SingleInstance Force
#Requires Autohotkey v2
SplitPath(A_AppData, , &appData)

Product := appData "\Local\Programs\VSCodium\resources\app\product.json"
Product_backup := appData "\Local\Programs\VSCodium\resources\app\product_backup.json"
Main()


Main()
{
    if FileExist(Product)
    {
        VSCodiumExtension(Product)
    }
    else
    {
        msg := Gui()
        msg.SetFont("s15")
        msg.Add("Text", , "VSCodium's product.json not found in appdata. Enter Path:")
        msg.Add("Edit", "w300 h20 vPath")
        msg.Add("Button", "w100", "Browse").OnEvent("Click", "Browse")
        msg.Add("Button", "x+10 w100", "Confirm")
        msg.Show()
        Browse(*)
        {
            SelectedFile := FileSelect(3, , "Open a file", "Text Documents (*.txt; *.doc)")
            if SelectedFile = ""
                MsgBox "Nvm."
            else
            {
                if FileExist(SelectedFile)
            }

        }
    }
}

class VSCodiumExtension
{
    static Call(path)
    {
        jdata := VSCodiumExtension.Read(path)
        VSCodiumExtension.Write(Product_backup, FileRead(Product))
    }

    static Write(Path, Str) => FileOpen(Path, "w").Write(Str)

    static Read(SelectedFile)
    {
        return Jsons.Loads(&x := FileRead(SelectedFile))
    }

    static UpdateJdata(&jdata)
    {
        jdata["extensionsGallery"]["serviceUrl"] := "https://marketplace.visualstudio.com/_apis/public/gallery"
        jdata["extensionsGallery"]["itemUrl"] := "https://marketplace.visualstudio.com/items"
        jdata["extensionsGallery"]["cacheUrl"] := "https://vscode.blob.core.windows.net/gallery/index"
        return jdata
    }
}

Sleep(1)


;==================================================
; Jsons.ahk - AutoHotkey JSON handling class
;==================================================
;
; This class provides methods to load and dump JSON data in AutoHotkey.
; It is based on the JXON library by TheArkive and coco.
;
; The Loads method parses a JSON string and returns a corresponding object.
; The Dumps method serializes an object into a JSON string.
;
; Credits:
; - JXON library by TheArkive: https://github.com/TheArkive/JXON_ahk2
; - Originally posted by user coco on AutoHotkey.com: https://github.com/cocobelgica/AutoHotkey-JSON
;
;==================================================
class Jsons
{
    static Loads(&src, args*)
    {
        key := "", is_key := false
        stack := [tree := []]
        next := '"{[01234567890-tfn'
        pos := 0

        while ((ch := SubStr(src, ++pos, 1)) != "") {
            if InStr(" `t`n`r", ch)
                continue
            if !InStr(next, ch, true) {
                testArr := StrSplit(SubStr(src, 1, pos), "`n")

                ln := testArr.Length
                col := pos - InStr(src, "`n", , -(StrLen(src) - pos + 1))

                msg := Format("{}: line {} col {} (char {})"
                    , (next == "") ? ["Extra data", ch := SubStr(src, pos)][1]
                    : (next == "'") ? "Unterminated string starting at"
                        : (next == "\") ? "Invalid \escape"
                        : (next == ":") ? "Expecting ':' delimiter"
                        : (next == '"') ? "Expecting object key enclosed in double quotes"
                        : (next == '"}') ? "Expecting object key enclosed in double quotes or object closing '}'"
                        : (next == ",}") ? "Expecting ',' delimiter or object closing '}'"
                        : (next == ",]") ? "Expecting ',' delimiter or array closing ']'"
                        : ["Expecting JSON value(string, number, [true, false, null], object or array)"
                            , ch := SubStr(src, pos, (SubStr(src, pos) ~= "[\]\},\s]|$") - 1)][1]
                    , ln, col, pos)

                throw Error(msg, -1, ch)
            }

            obj := stack[1]
            is_array := (obj is Array)

            if i := InStr("{[", ch) { ; start new object / map?
                val := (i = 1) ? Map() : Array()	; ahk v2

                is_array ? obj.Push(val) : obj[key] := val
                stack.InsertAt(1, val)

                next := '"' ((is_key := (ch == "{")) ? "}" : "{[]0123456789-tfn")
            } else if InStr("}]", ch) {
                stack.RemoveAt(1)
                next := (stack[1] == tree) ? "" : (stack[1] is Array) ? ",]" : ",}"
            } else if InStr(",:", ch) {
                is_key := (!is_array && ch == ",")
                next := is_key ? '"' : '"{[0123456789-tfn'
            } else { ; string | number | true | false | null
                if (ch == '"') { ; string
                    i := pos
                    while i := InStr(src, '"', , i + 1) {
                        val := StrReplace(SubStr(src, pos + 1, i - pos - 1), "\\", "\u005C")
                        if (SubStr(val, -1) != "\")
                            break
                    }
                    if !i ? (pos--, next := "'") : 0
                        continue

                    pos := i ; update pos

                    val := StrReplace(val, "\/", "/")
                    val := StrReplace(val, '\"', '"')
                        , val := StrReplace(val, "\b", "`b")
                        , val := StrReplace(val, "\f", "`f")
                        , val := StrReplace(val, "\n", "`n")
                        , val := StrReplace(val, "\r", "`r")
                        , val := StrReplace(val, "\t", "`t")

                    i := 0
                    while i := InStr(val, "\", , i + 1) {
                        if (SubStr(val, i + 1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
                            continue 2

                        xxxx := Abs("0x" . SubStr(val, i + 2, 4)) ; \uXXXX - JSON unicode escape sequence
                        if (xxxx < 0x100)
                            val := SubStr(val, 1, i - 1) . Chr(xxxx) . SubStr(val, i + 6)
                    }

                    if is_key {
                        key := val, next := ":"
                        continue
                    }
                } else { ; number | true | false | null
                    val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$", , pos) - pos)

                    if IsInteger(val)
                        val += 0
                    else if IsFloat(val)
                        val += 0
                    else if (val == "true" || val == "false")
                        val := (val == "true")
                    else if (val == "null")
                        val := ""
                    else if is_key {
                        pos--, next := "#"
                        continue
                    }

                    pos += i - 1
                }

                is_array ? obj.Push(val) : obj[key] := val
                next := obj == tree ? "" : is_array ? ",]" : ",}"
            }
        }
        return tree[1]
    }


    static Dumps(obj, indent := "", lvl := 1)
    {
        if IsObject(obj) {
            if obj.__Class = "Object" {
                obj := Jsons.ConvertObjectToMap(obj)
            } else if not (obj is Array || obj is Map || obj is String || obj is Number) && obj.__Class != "BoundaryFunc" {
                obj := Jsons.ConvertObjectToMap(obj)
            }
            If !(obj is Array || obj is Map || obj is String || obj is Number)
                throw Error("Object type not supported.", -1, Format("<Object at 0x{:p}>", ObjPtr(obj)))

            if IsInteger(indent)
            {
                if (indent < 0)
                    throw Error("Indent parameter must be a postive integer.", -1, indent)
                spaces := indent, indent := ""

                Loop spaces ; ===> changed
                    indent .= " "
            }
            indt := ""

            Loop indent ? lvl : 0
                indt .= indent

            is_array := (obj is Array)

            lvl += 1, out := "" ; Make #Warn happy
            for k, v in obj {
                ; if IsObject(k) || (k == "")
                ;  throw Error("Invalid object key.", -1, k ? Format("<Object at 0x{:p}>", ObjPtr(obj)) : "<blank>")
                if !is_array  ;// key ; ObjGetCapacity([k], 1)
                    out .= (ObjGetCapacity([k]) ? Jsons.Dumps(k) : escape_str(k)) (indent ? ": " : ":") ; token + padding
                out .= Jsons.Dumps(v, indent, lvl) ; value
                    . (indent ? ",`n" . indt : ",") ; token + indent
            }

            if (out != "") {
                out := Trim(out, ",`n" . indent)
                if (indent != "")
                    out := "`n" . indt . out . "`n" . SubStr(indt, StrLen(indent) + 1)
            }

            return is_array ? "[" . out . "]" : "{" . out . "}"

        } Else If (obj is Number)
            return obj
        Else ; String
            return escape_str(obj)

        escape_str(obj) {
            obj := StrReplace(obj, "\", "\\")
            obj := StrReplace(obj, "`t", "\t")
            obj := StrReplace(obj, "`r", "\r")
            obj := StrReplace(obj, "`n", "\n")
            obj := StrReplace(obj, "`b", "\b")
            obj := StrReplace(obj, "`f", "\f")
            obj := StrReplace(obj, "/", "\/")
            obj := StrReplace(obj, '"', '\"')

            return '"' obj '"'
        }
    }
    static ConvertObjectToMap(InputObject) {
        if IsObject(InputObject) {
            if InputObject.__Class = "Map" {
                return InputObject
            }
            else {
                return Jsons.convertObj(InputObject)
            }
        }
        else {
            return InputObject
        }
    }
    static convertObj(obj) {
        convertedObject := Map()
        for k, v in obj.OwnProps() {
            if v.base.__Class != "BoundFunc" {
                convertedObject.Set(k, v)
            }
        }
        return convertedObject
    }
}