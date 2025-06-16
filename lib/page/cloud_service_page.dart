import 'package:flutter/material.dart';
import 'package:pilot_mocker/page/thirdpart_cloud_page.dart';

class CloudServicePage extends StatelessWidget {
  const CloudServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: const Color.fromARGB(255, 233, 233, 233),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    style: ButtonStyle(iconSize: WidgetStateProperty.all(24)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text('云服务', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                  SizedBox(width: 1),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: const [Icon(Icons.settings_system_daydream, size: 48, color: Colors.blue)],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('司空 2', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Text('功能特性', style: TextStyle(fontSize: 14, color: Colors.blue)),
                                    Text('数据隐私说明', style: TextStyle(fontSize: 14, color: Colors.blue)),
                                  ],
                                ),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              // 导航到第三方云界面
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ThirdPartCloudPage()));
                            },
                            child: Container(
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud, size: 48, color: Colors.black),
                                  SizedBox(height: 8),
                                  Text('开放平台', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.star, size: 48, color: Colors.blue),
                                      Text('GB28181', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.smart_display, size: 48, color: Colors.blue),
                                      Text('自定义直播', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
