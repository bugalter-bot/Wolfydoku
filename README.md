# Meow Puzzle: 2-bosqich (Godot 4.x)

## Ishga tushirish (kompyuterda)
1. Godot 4.x ni oching, Project Manager'da **Import** bosing.
2. `project.godot` faylini tanlab, **Import & Edit**.
3. **F5** (yoki o'ng tepadagi Play tugmasi). Oyna 540x960 portret ko'rinishida ochiladi.

## O'ynash
- **Bir tap**: katakka X qo'yish (yana bosilsa olib tashlanadi).
- **Tez ikki tap** (0.35 soniya ichida): mushuk qo'yish.
- Xato mushuk = 1 yurak yo'qoladi. 3 yurak tugasa level qaytadan.
- To'g'ri mushukdan keyin qator, ustun, hudud va qo'shni kataklarga X avtomatik qo'yiladi.
- Kompyuterda test: **N** = keyingi level, **P** = oldingi level.

## Fayllar
- `main.gd`: levellarni yuklash, yuraklar, g'alaba/yutqazish oynasi.
- `board.gd`: maydonni chizish, tap'lar, animatsiya (mushuk bounce, xato silkinishi, qizil chaqnash).
- `levels.json`: 1-bosqichda yaratilgan 105 level.

## Android telefonda sinash (qisqa)
Versiyalar o'zgarib turadi, aniq talablar uchun Godot hujjatidagi **"Exporting for Android"** sahifasiga qarang.
1. **JDK 17** o'rnating.
2. **Android Studio** o'rnating (yoki faqat SDK command-line tools) va SDK Manager'dan Godot hujjati aytgan Platform-Tools, Build-Tools, Platform va CMake'ni yuklang.
3. Godot: **Editor > Editor Settings > Export > Android** bo'limida Java SDK Path va Android SDK Path ni ko'rsating. Debug keystore kerak bo'lsa hujjatdagi `keytool` buyrug'i bilan yarating.
4. **Project > Export > Add > Android**. Package Unique Name: `com.sizningism.meowpuzzle`. **Resources** tabida "Filters to export non-resource files" maydoniga `*.json` yozing (aks holda levels.json telefonda topilmaydi!).
5. Telefonda: Sozlamalar > Telefon haqida > "Build number" ga 7 marta bosing (Developer mode), keyin Developer options > **USB debugging** yoqing. USB bilan ulang, "Allow" deng.
6. Godot o'ng tepasida Android belgisi paydo bo'ladi. Bosing, o'yin telefonga o'rnatilib ochiladi.
