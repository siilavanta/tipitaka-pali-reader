import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tipitaka_pali/app.dart';
import 'package:tipitaka_pali/business_logic/view_models/reader_view_model.dart';
import 'package:tipitaka_pali/ui/dialogs/simple_input_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ReaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ReaderAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ReaderViewModel>(context, listen: false);
    myLogger.i('Building Appbar');
    return AppBar(
      title: Text(vm.book.name),
      actions: [
        IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: vm.increaseFontSize),
        IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: vm.decreaseFontSize),
        IconButton(
            icon: const Icon(Icons.book_outlined),
            onPressed: () {
              _addBookmark(vm, context);
            }),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  void _addBookmark(ReaderViewModel vm, BuildContext context) async {
    final note = await showDialog<String>(
      context: context,
      builder: (context) {
        return  SimpleInputDialog(
            hintText: AppLocalizations.of(context)!.enter_note,
            cancelLabel: AppLocalizations.of(context)!.cancel,
            okLabel: AppLocalizations.of(context)!.save,
        );
        
      },
    );
    //print(note);
    if (note != null) {
      vm.saveToBookmark(note);
    }
  }
}
