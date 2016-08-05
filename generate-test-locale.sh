#!/bin/bash

DEST=$1

if [ x$DEST = x ]; then
  echo "Destination directory where to create local directory must be given as the first argument"
  exit 1
fi

if ! [ -d $DEST ]; then
  echo "Destination $DEST does not exist"
  exit 1
fi

if [ -e $DEST/locale ]; then
  echo "$DEST/locale already exists"
  exit 1
fi

PL_DEST=$DEST/locale/pl/LC_MESSAGES
mkdir -p $PL_DEST
cat > $PL_DEST/anki.po <<EOL
msgid ""
msgstr ""
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"
"Plural-Forms: nplurals=3; plural=n==1 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 "
"|| n%100>=20) ? 1 : 2;\n"
"Language: pl\n"

msgid "Again"
msgstr "Znowu"

msgid "Good"
msgstr "Dobra"

msgid "Easy"
msgstr "Łatwa"

msgid "%s minute"
msgid_plural "%s minutes"
msgstr[0] "%s minuta"
msgstr[1] "%s minuty"
msgstr[2] "%s minut"

msgid "%s day"
msgid_plural "%s days"
msgstr[0] "%s dzień"
msgstr[1] "%s dni"
msgstr[2] "%s dni"
EOL

(cd $PL_DEST && msgfmt anki.po --output-file anki.mo)

