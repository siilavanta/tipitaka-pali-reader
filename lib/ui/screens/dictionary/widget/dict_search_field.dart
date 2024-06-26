import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:tipitaka_pali/services/database/database_helper.dart';
import 'package:tipitaka_pali/services/prefs.dart';
import 'package:tipitaka_pali/services/repositories/dictionary_history_repo.dart';
import 'package:tipitaka_pali/utils/pali_script_converter.dart';

import '../../../../services/provider/script_language_provider.dart';
import '../../../../utils/pali_script.dart';
import '../../../../utils/pali_tools.dart';
import '../../../../utils/script_detector.dart';
import '../controller/dictionary_controller.dart';

class DictionarySearchField extends StatefulWidget {
  const DictionarySearchField({
    super.key,
  });

  @override
  State<DictionarySearchField> createState() => _DictionarySearchFieldState();
}

class _DictionarySearchFieldState extends State<DictionarySearchField> {
  late final TextEditingController textEditingController;
  late final DictionaryController dictionaryController;
  ValueNotifier<bool> showClearButton = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    dictionaryController = context.read<DictionaryController>();
    textEditingController = TextEditingController();

    final lookupWord = dictionaryController.lookupWord;
    if (lookupWord.isNotEmpty) {
      textEditingController.text = PaliScript.getScriptOf(
          script: context.read<ScriptLanguageProvider>().currentScript,
          romanText: lookupWord);
    } else {
      textEditingController.text = '';
    }
    dictionaryController.addListener(_lookUpWordListener);
    textEditingController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    showClearButton.value = textEditingController.text.isNotEmpty;
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void _lookUpWordListener() {
    final lookupWord = dictionaryController.lookupWord;
    if (lookupWord.isNotEmpty) {
      textEditingController.text = PaliScript.getScriptOf(
          script: context.read<ScriptLanguageProvider>().currentScript,
          romanText: lookupWord);
    } else {
      textEditingController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
            autocorrect: false,
            controller: textEditingController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              suffixIcon: ValueListenableBuilder(
                  valueListenable: showClearButton,
                  builder: (context, isVisible, _) {
                    return Visibility(
                        visible: isVisible,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: IconButton(
                            onPressed: () {
                              textEditingController.clear();
                              // dictionaryController.onClickedHistoryButton();
                            },
                            icon: const Icon(Icons.clear),
                          ),
                        ));
                  }),
            ),
            onSubmitted: (word) async {
              await insertHistory(word);
              context.read<DictionaryController>().onLookup(word);
            },
            onChanged: (text) {
              String inputText = text;
              final inputScript = ScriptDetector.getLanguage(inputText);

              // convert velthuis input to uni
              if (text.isNotEmpty) {
                // text controller naturally pushes to the beginning
                // fixed to keep natural position

                // before conversion get cursor position and length
                int origTextLen = text.length;
                int pos = textEditingController.selection.start;

                if (!Prefs.disableVelthuis && inputScript == Script.roman) {
                  final uniText = PaliTools.velthuisToUni(velthiusInput: text);
                  // after conversion get length and add the difference (if any)
                  int uniTextlen = uniText.length;
                  textEditingController.text = uniText;
                  textEditingController.selection = TextSelection.fromPosition(
                      TextPosition(offset: pos + uniTextlen - origTextLen));
                }
              } else {
                context.read<DictionaryController>().onInputIsEmpty();
              }
            }),
        suggestionsCallback: (text) async {
          if (text.isEmpty) {
            return <String>[];
          } else {
            final inputLanguage = ScriptDetector.getLanguage(text);
            final romanText = PaliScript.getRomanScriptFrom(
                script: inputLanguage, text: text);
            final suggestions = await context
                .read<DictionaryController>()
                .getSuggestions(romanText);
            return suggestions;
          }
        },
        debounceDuration: Duration.zero,
        itemBuilder: (context, String suggestion) {
          return ListTile(
              title: Text(PaliScript.getScriptOf(
                  script: context.read<ScriptLanguageProvider>().currentScript,
                  romanText: suggestion)));
        },
        onSuggestionSelected: (String suggestion) async {
          final inputLanguage =
              ScriptDetector.getLanguage(textEditingController.text);
          textEditingController.text = PaliScript.getScriptOf(
              script: inputLanguage, romanText: suggestion);
          await insertHistory(suggestion);
          context.read<DictionaryController>().onLookup(suggestion);
        });
  }

  insertHistory(word) async {
    final DictionaryHistoryDatabaseRepository dictionaryHistoryRepository =
        DictionaryHistoryDatabaseRepository(dbh: DatabaseHelper());

    await dictionaryHistoryRepository.insert(word, "", 1, "");
  }
}
