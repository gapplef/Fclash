import 'dart:io';

import 'package:fclash/service/clash_service.dart';
import 'package:flutter/material.dart';
import 'package:kommon/kommon.dart';
import 'package:path/path.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Obx(() => BrnNoticeBar(
              content:
                  'Current using: ${Get.find<ClashService>().currentYaml.value}')),
          Expanded(child: Obx(() => buildProfileList()))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addProfile();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildProfileList() {
    final configs = Get.find<ClashService>().yamlConfigs;
    if (configs.isEmpty) {
      return BrnAbnormalStateWidget(
        title: 'No profile, please add profiles by ADD button below.',
      );
    } else {
      return ListView.builder(
        itemCount: configs.length,
        itemBuilder: (context, index) {
          final filename = basename(configs[index].path);
          return Obx(
            () => InkWell(
              onTap: () => handleProfileClicked(configs[index],
                  Get.find<ClashService>().currentYaml.value == filename),
              child: Container(
                  decoration: BoxDecoration(
                      color:
                          Get.find<ClashService>().currentYaml.value == filename
                              ? Colors.blueAccent
                              : Colors.transparent),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(
                        basename(
                          configs[index].path,
                        ),
                        style: TextStyle(fontSize: 24),
                      )),
                      const Icon(Icons.keyboard_arrow_right)
                    ],
                  )),
            ),
          );
        },
      );
    }
  }

  void _addProfile() {}

  handleProfileClicked(FileSystemEntity config, bool isInUse) {
    Get.bottomSheet(BrnCommonActionSheet(
      title: basename(config.path),
      actions: [
        BrnCommonActionSheetItem('set to default profile',
            desc:
                isInUse ? "already default profile" : "switch to this profile"),
        BrnCommonActionSheetItem('DELETE', desc: "delete this profile"),
      ],
      cancelTitle: 'Cancel',
      onItemClickInterceptor: (index, a) {
        switch (index) {
          case 0:
            if (!isInUse) {
              Get.find<ClashService>().changeYaml(config).then((value) {
                if (value) {
                  Get.snackbar("Success", "update yaml config success!",
                      snackPosition: SnackPosition.BOTTOM);
                } else {
                  Get.snackbar("Failed",
                      "update yaml config failed! Please check yaml file.",
                      snackPosition: SnackPosition.BOTTOM);
                }
              });
            }
            break;
          case 1:
            if (isInUse) {
              Get.dialog(BrnDialog(
                titleText: "You can't delete a profile which is in use!",
                contentWidget: Center(
                    child:
                        const Text('Please switch to another profile first.')),
                actionsText: ["OK"],
              ));
            } else {
              Get.find<ClashService>().deleteYaml(config);
            }
            break;
        }
        return false;
      },
    ));
  }
}
