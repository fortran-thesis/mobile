import 'package:flutter/material.dart';
import 'package:moldify/pages/misc/colors.dart';

import '../misc/appbar/secondary_appbar.dart';

class CodeRecoverAccountScreen extends StatefulWidget {
  final String pageTitle;

  const CodeRecoverAccountScreen({
    super.key,
    required this.pageTitle
  });

  @override
  State<CodeRecoverAccountScreen> createState() => _CodeRecoverAccountScreenState();
}
class _CodeRecoverAccountScreenState extends State<CodeRecoverAccountScreen> {
  final TextEditingController _codeController = TextEditingController();
  /// currentStep keeps track of the current step in the recovery process.
  int currentStep = 0;
  /// totalSteps is the total number of steps in the recovery process.
  late final int totalSteps;
  /// title is the app bar title of the page, which is set based on the pageTitle passed to the widget.
  /// It can be 'Forgot Username', 'Forgot Password'.
  late final String title;

  /// It initializes the title and totalSteps based on the pageTitle passed to the widget.
  /// If the pageTitle is 'Forgot Username', it sets the title to 'Forgot Username' and totalSteps to 2.
  /// If the pageTitle is 'Forgot Password', it sets the title to 'Forgot Password' and totalSteps to 3.
  @override
  void initState() {
    super.initState();
    if(widget.pageTitle == 'Forgot Username'){
      title = 'Forgot Username';
      totalSteps = 2;
    } else if(widget.pageTitle == 'Forgot Password'){
      title = 'Forgot Password';
      totalSteps = 3;
    } else {
      title = widget.pageTitle;
      totalSteps = 0;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoldifyColors.backgroundColor,
      appBar: SecondaryAppBar(
        title: title,
        color: MoldifyColors.primaryColor,
      ),
      body: SingleChildScrollView(

      )
    );
  }
}