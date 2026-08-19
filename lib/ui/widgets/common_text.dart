import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';

class MyText extends StatelessWidget {
  final String? text;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? color;
  final String? fontFamily;
  final FontStyle? fontStyle;
  final TextDecoration? textDecoration;
  final double? letterSpacing;
  final double? wordSpacing;
  final int? maxLines;
  final TextOverflow? overflow;

  const MyText({
    super.key,
    required this.text,
    this.fontWeight,
    this.fontSize,
    this.color,
    this.fontFamily,
    this.fontStyle,
    this.textDecoration,
    this.letterSpacing,
    this.wordSpacing, this.maxLines, this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    // TextStyle style = GoogleFonts.getFont(
    //   fontFamily,
    //   fontWeight: fontWeight,
    //   fontSize: fontSize,
    //   color: color,
    //   fontStyle: fontStyle,
    //   decoration: textDecoration,
    //   letterSpacing: letterSpacing,
    //   wordSpacing: wordSpacing,
    // );

    return Text(
      text!,
      style: TextStyle(
        fontFamily: fontFamily,
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: color,
        fontStyle: fontStyle,
        decoration: textDecoration,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        overflow: overflow ?? TextOverflow.ellipsis,
      ),
        maxLines:maxLines
      // textAlign: TextAlign.center,
    );
  }
}