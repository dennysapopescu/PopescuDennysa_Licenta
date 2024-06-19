# ChitChat - Aplicație mobilă de mesagerie

ChitChat este o aplicație realizată cu ajutorul Flutter și Firebase. Acest ghid vă va ajuta să configurați mediul de dezvoltare, Firebase și să adăugați dispozitive virtuale pentru a putea rula aplicația.

## Link-uri utile

- [Flutter](https://flutter.dev/docs/get-started/install)
- [Dart](https://dart.dev/get-dart)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Android Studio](https://developer.android.com/studio)

## Ghid pentru configurarea aplicației

### Pasul 1: Instalați pluginurile Flutter și Dart în Visual Studio Code

1. Deschideți Visual Studio Code.
2. Accesați extensiile cu clic pe pictograma Extensii din Bara de Activități sau cu comanda `Ctrl+Shift+X`.
3. Căutați `Flutter` și faceți clic pe `Instalează`.
4. Similar, căutați `Dart` și faceți clic pe `Instalează`.

### Pasul 2: Configurați Flutter în Visual Studio Code

1. Deschideți terminalul în Visual Studio Code (`Ctrl+` ` sau prin meniul `Terminal > New Terminal`).
2. Verificați instalarea rulând comanda:   flutter doctor

### Pasul 3: Clonați repository-ul cu codul sursă al aplicației 

1. Deschideți terminalul
2. Pentru a clona repository-ul aplicației folosiți comanda: git clone https://github.com/dennysapopescu/PopescuDennysa_Licenta.git
3. Apoi navigați în folderul proiectului.

### Instalați dependențele

1. După ce v-ați asigurat că Flutter și Dart sunt instalate și configurate corect, deschideți terminalul și rulați comanda: flutter pub get

### Configurarea Firebase

1. Nu va fi nevoie să configurați Firebase, deoarece aplicația este deja configurată pentru a utiliza un proiect Firebase existent.
2. Trebuie doar să vă asigurați că fișierele de configurare Firebase sunt plasate corect, mai exact, să vă asigurați că fișierul google-services.json este plasat în directorul android/app.

### Adăugarea dispozitivelor virtuale cu ajutorul Android Studio

1. Deschideți Android Studio.
2. Accesați secțiunea AVD Manager din meniul Configure sau făcând clic pe pictograma AVD Manager.
3. Clic pe Create Virtual Device.
4. Selectați o definiție a dispozitivului și apoi apăsați Next.
5. Selectați o imagine de sistem și apăsați pe Next.
6. Verificați configurația și apăsați Finish.
7. Porniți dispozitivul virtual din AVD Manager.

### Pasul 5: Adăugați Dispozitive Virtuale în Visual Studio Code

1. Asigurați-vă că dispozitivul virtual este pornit.
2. În Visual Studio Code, deschideși Command Palette (Ctrl+Shift+P).
3. Tastați și selectați Flutter: Select Device.
4. Selectați dispozitivul virtual pornit din listă.
   
### Pasul 6: Rularea Aplicației

1. Deschideți proiectul Flutter în Visual Studio Code.
2. Selectați dispozitivul țintă din bara de stare de jos, iar apoi accesați pictograma Run and Debug din Bara de Activități.

### Nu uitați:

Asigurați-vă că fișierul google-services.json se află în locația corectă.
Rulați comanda flutter doctor pentru a verifica eventualele probleme și urmați instrucțiunile pentru a le rezolva.
