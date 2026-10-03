# Wolfy Doku - loyiha konteksti (Claude uchun)

Sen menga Godot o'yinimni dizayn va animatsiya bo'yicha yaxshilashda yordam berasan.
Javoblarni O'ZBEK tilida yoz, qisqa va telefon ekraniga mos (1-2 ekran), avval javob, keyin izoh. Bir vaqtda bitta qadam ber.

Kod GitHub'da: https://github.com/bugalter-bot/Wolfydoku (main.gd, board.gd, palette.gd). Faqat kerakli faylni o'qi (UI uchun main.gd, taxta uchun board.gd), hammasini emas.

## Loyiha
- "Wolfy Doku" (avval Meow Puzzle): Queens/Meowdoku uslubidagi 2D mantiqiy o'yin. Qoida: har qator, ustun va rangli hududda 1 ta bo'ri bolasi, bo'rilar bir-biriga (diagonal ham) tegmaydi. 1 tap = X, tez 2 tap = bo'ri. 3 yurak, taymer, hint (lampochka = aqlli yordam, bo'ri tugmasi = bo'rini ko'rsat), kunlik reyting (botlar bilan simulyatsiya).
- Godot 4.7.2, Android TELEFONDAGI muharrirda ishlayman (interfeys ruscha). Viewport 1080x1920, stretch canvas_items/expand, portrait.
- Fayllar (res://): main.tscn (faqat Main node), main.gd (butun UI kod bilan), board.gd (class_name Board, _draw), palette.gd (Autoload "Palette"), levels.json, icon.png, assets/wolf.png (bosh), assets/wolf_full.png (to'liq tana), assets/fonts/ (Nunito), assets/sfx/ (tap, mark, unmark, pop, wrong, win .wav).
- Faqat BEPUL vositalar. Animatsiya Godot kodida (Tween, _draw, CPUParticles2D).

## Telefon cheklovlari
1. Godot muharririga KATTA matn/emoji yopishtirib bo'lmaydi ("invalid utf16 surrogate"). To'liq fayllarni YUKLAB OLINADIGAN FAYL qilib ber; men Fayllar ilovasi orqali almashtiraman, so'ng "Проект -> Перезагрузить текущий проект".
2. Kichik o'zgarish uchun ham fayl ber (klaviatura avtotuzatadi).
3. O'zgartirishdan oldin zaxira eslat; zaxirani loyiha papkasidan TASHQARIGA qo'y (ikkita class_name Board xato beradi).
4. Kodda emoji o'rniga \U0001F41F kabi escape ishlat.

## Bajarilgan
Krem fon, yumaloq rangli kataklar, yumaloq uchli oq X (bounce), Nunito shrifti (Theme), oq yumaloq tugmalar, progress pill, pastki doira tugmalar (kod bilan chizilgan ikonlar), yumshoq yuraklar + yo'qolish animatsiyasi, bo'ri rasmi katakda (pop + yulduzchalar), ovozlar, xavfsiz chekka/uzun ekran joylashuvi, matnlar "bo'ri"ga o'zgargan, ikonka, yangi reyting oynasi, celebration oynasi (nurlar, bo'ri, maqtov, Level N tugmasi). Tartib: daraja tugadi -> reyting -> bosish -> celebration -> Level N. Kunlik jumboqda faqat reyting.

## Keyingi reja
1. Reyting/celebration ni sinash va tuzatish.
2. Bosh ekran (katta bo'ri, "Wolfy Doku", O'ynash tugmasi, Kunlik jumboq, sozlamalar).
3. Sozlamalar sayqali.
4. Yakuniy tekshiruv va APK eksport (o'yin tugagach).
