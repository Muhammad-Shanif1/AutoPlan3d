import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';



class MenubarControlller extends GetxController {
  RxInt  currentIndex = 0.obs;
  PageController controller = PageController();

  onpagechange(index){
    if(index==currentIndex.value+1 || index==currentIndex.value-1){
    controller.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    }else{
      print("else");
    controller.jumpToPage(index);
    }
    currentIndex.value=index;
  }
}