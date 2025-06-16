import 'package:flutter/material.dart';
import 'package:pilot_mocker/page/cloud_service_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: const Color.fromARGB(255, 233, 233, 233),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.person),
                          style: ButtonStyle(iconSize: WidgetStateProperty.all(24)),
                          onPressed: () {
                            // Navigate to settings page
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.shield),
                          style: ButtonStyle(iconSize: WidgetStateProperty.all(24)),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            height: 88,
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('限高500m', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text('utmiss', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                  ],
                                ),
                                const Icon(Icons.location_on),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4),
                            onTap: () {
                              Navigator.of(context).pushNamed('/cloud_service');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              height: 88,
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('欢迎使用', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      Text('请登录以继续', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                    ],
                                  ),
                                  const Icon(Icons.cloud),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            height: 88,
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('航线', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const Icon(Icons.edit_road),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            height: 88,
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('相册', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const Icon(Icons.photo_library),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.grey[200],
                        child: Center(
                          child: Text(
                            'Welcome to Pilot 2 Mocker',
                            // 白色
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    Text('请选择飞行器', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text('Adjust your settings here.', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
