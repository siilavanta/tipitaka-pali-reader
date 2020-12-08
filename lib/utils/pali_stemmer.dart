class PaliStemmer {
  static String getStem(String word) {
    String stemWord = word.trim();
    // remove punctuation
    stemWord = stemWord.replaceAll(
        new RegExp(r'[\u104a\u104b\u2018\u2019",\.\?]'), '');

    // various ending of pada
    List<RegExp> endings = [];

    endings.add(new RegExp(r'\u1031\u1014$')); // ena ေန
    endings.add(new RegExp(r'\u1031[\u101f\u1018]\u102d$')); // ehi ebhi ေဟိ ေဘိ
    endings.add(new RegExp(r'\u103f$')); // ssa ဿ
    // naṃ (နံ) preceded by vowel ā or ī or ū
    // first, will find with dīgha vowel in dict
    // if not find , convert to rassa vowel and will find again
    endings.add(new RegExp(r'(?<=[\u102b\u102c\u102e\u1030])\u1014\u1036$'));
    endings.add(new RegExp(r'\u101e\u1039\u1019\u102c$')); // smā သ္မာ
    endings.add(new RegExp(r'\u1019\u103e\u102c$')); // mhā မှာ
    endings.add(new RegExp(r'\u101e\u1039\u1019\u102d\u1036$')); // smiṃ သ္မိံ
    endings.add(new RegExp(r'\u1019\u103e\u102d$')); // mhi မှိ
    endings.add(new RegExp(r'\u1031\u101e\u102f$')); // esu ေသု
    // cittādigana
    endings
        .add(new RegExp(r'[\u102b\u102c]\u1014\u102d$')); // // āni ါနိ or ာနိ
    // kannādigana etc
    endings.add(new RegExp(
        r'(?<=[\u102b\u102c\u102d])\u101a\u1031\u102c$')); // āyo ါယော or ာယော
    endings.add(new RegExp(r'(?<=[\u102d])\u101a\u102c$')); // iyā ိယာ
    endings.add(new RegExp(
        r'(?<=[\u102b\u102c])\u101a\u1036?$')); //  āya or āyaṃ  ါယ or ါယံ or ာယ or ာယံ
    // su (သု) preceded by vowel ā or ī or ū
    // first, will find with dīgha vowel in dict
    // if not find , convert to rassa vowel and will find again
    endings.add(new RegExp(
        r'(?<=[\u102b\u102c\u102d\u102e\u102f\u1030])\u101e\u102f?$'));

    endings.add(new RegExp(r'\u1031[\u102b\u102c]$')); // dependent vowel O ော
    endings.add(new RegExp(r'\u1031$')); // dependent vowel E ေ
    endings.add(new RegExp(r'\u1036$')); // niggahita ṃ ံ

    for (RegExp ending in endings) {
      if (ending.hasMatch(stemWord)) {
        stemWord = stemWord.replaceAll(ending, '');
        break;
      }
    }

    return stemWord;
  }

  static bool isEndWithRassa(String word) {
    return new RegExp(r'[\u1000-\u1020\u102d\u102f]').hasMatch(word);
  }

  static bool isEndWithDigha(String word) {
    return new RegExp(r'[\u102b\u102c\u102e\u1030]').hasMatch(word);
  }

  static String convertToDigha(String word) {
    String _word = word;
    int length = _word.length;

    if (word.endsWith('\u102d')) {
      _word = _word.substring(0, length - 1) + "\u102e";
    } else if (word.endsWith("\u102f")) {
      _word = _word.substring(0, length - 1) + "\u1030";
    } else {
      // TODO to insert suitable shape of dependent vowel ā
      String lastChar = _word.substring(length - 1, length);
      if ("ခဂဒပဝ".contains(lastChar))
        _word = _word + "\u102b";
      else
        _word = _word + "\u102c";
    }

    return _word;
  }

  static String convertToRassa(String word) {
    String _word = word;
    int length = _word.length;

    if (word.endsWith("\u102e")) {
      _word = _word.substring(0, length - 1) + "\u102d";
    } else if (word.endsWith("\u1030")) {
      _word = _word.substring(0, length - 1) + "\u102f";
    } else {
      _word = _word.substring(0, length - 1);
    }

    return _word;
  }
}
