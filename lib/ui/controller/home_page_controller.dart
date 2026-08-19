import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/ui/models/project_model.dart';
import 'package:flutter_unity_widget_example/ui/services/project_services.dart';
import 'package:get/get.dart';
// import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'dart:convert';
class HomePageController extends GetxController {

  // Projects list
  var projects = <Project>[].obs;
  var isLoading = false.obs;
  var createloading=false.obs;
  @override
  void onInit() {
    projects.value = ProjectService.instance.projects;
    // setupUnityListeners();
    super.onInit();
  }

  @override
  void onReady() {
    print('🏠 HomePageController onReady');
    super.onReady();
  }


  @override
  void onClose() {
    // unityController?.dispose();
    // unityManager.dispose();
    super.onClose();
  }
}