import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final void Function() onPressed;
  final Color? color;
  final double? width;
  final double? height;
  final bool isIconShown;
  final IconData? icondata;

  const CommonButton(
      {super.key, required this.text,
        this.textStyle,
        required this.onPressed,
        this.isIconShown = false,
        this.icondata,
        this.color,
        this.width,
        this.height});

  @override
  Widget build(BuildContext context) {
    return
      SizedBox(
        height: height,
        width: width,
        child: ElevatedButton(

          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),backgroundColor: color??Colors.black,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: textStyle ??
                    TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                maxLines: 2,
              ),
              const SizedBox(
                width: 5,
              ),
              isIconShown == true
                  ? Icon(
                icondata,
                color: Colors.white,
                size: 20,
              )
                  : const SizedBox()
            ],
          ),
        ),
      );
  }
}

// ---------------------------------------- Icon Button ----------------------------------------------------

class CommonIconbutton extends StatelessWidget {
  final IconData iconData;
  final Color? color;
  final double? size;
  final TextDirection? textDirection;
  final String? semanticLabel;
  final bool? isButton;
  final VoidCallback? onPressed;

  const CommonIconbutton({
    super.key,
    required this.iconData,
    this.color,
    this.size,
    this.textDirection,
    this.semanticLabel,
    this.isButton = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return isButton!
        ? IconButton(
      padding: const EdgeInsets.all(0),
      icon: Icon(
        iconData,
        color: color,
        size: size,
        textDirection: textDirection,
        semanticLabel: semanticLabel,
      ),
      onPressed: onPressed,
    )
        : Icon(
      iconData,
      color: color,
      size: size,
      textDirection: textDirection,
      semanticLabel: semanticLabel,
    );
  }
}
