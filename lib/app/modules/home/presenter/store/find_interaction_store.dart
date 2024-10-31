import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class FindInteractionStore {
  FindInteractionController? findInteractionController;
  final ValueNotifier<String> textFound = ValueNotifier<String>("");

  final ValueNotifier<bool> search = ValueNotifier<bool>(false);

  void setFindInteraction({required BuildContext context}) {
    findInteractionController = FindInteractionController(
      onFindResultReceived: (controller, activeMatchOrdinal, numberOfMatches,
          isDoneCounting) async {
        if (isDoneCounting) {
          // setState(() {
          textFound.value = numberOfMatches > 0
              ? '${activeMatchOrdinal + 1} of $numberOfMatches'
              : '';
          // });
          if (numberOfMatches == 0) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Não encontramos o termo "${await findInteractionController!.getSearchText()}"'),
            ));
          }
        }
      },
    );
  }

  void setTextFound({required String text}) {
    textFound.value = '';
  }

  void setSearch({required bool value}) {
    search.value = value;

    if (!value) {
      findInteractionController!.clearMatches();
      setTextFound(text: '');
    }
  }
}
