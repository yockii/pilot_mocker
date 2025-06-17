import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThirdPartCloudPage extends StatefulWidget {
  const ThirdPartCloudPage({super.key});

  @override
  State<ThirdPartCloudPage> createState() => _ThirdPartCloudPageState();
}

class _ThirdPartCloudPageState extends State<ThirdPartCloudPage> {
  String _url = '';
  late final TextEditingController _controller;
  final List<String> _history = ['http://127.0.0.1:8081/pilot-login'];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _url);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('third_party_history');
    if (list != null) {
      setState(() {
        _history.clear();
        _history.addAll(list);
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('third_party_history', _history);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Material(
      child: Container(
        color: const Color.fromARGB(255, 233, 233, 233),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Navigation bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 60,
              color: Colors.white,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    style: ButtonStyle(iconSize: WidgetStateProperty.all(24)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text('第三方云', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.autorenew),
                        style: ButtonStyle(iconSize: WidgetStateProperty.all(24)),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          if (_url.isNotEmpty && !_history.contains(_url)) {
                            setState(() {
                              _history.add(_url);
                            });
                            _saveHistory();
                          }
                          Navigator.of(context).pushNamed('/web_view', arguments: {'url': _url});
                        },
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                          ),
                          backgroundColor: WidgetStateProperty.all(Colors.black),
                          foregroundColor: WidgetStateProperty.all(Colors.white),
                        ),
                        child: const Text('连接'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // URL input row (inline TextField)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text('URL链接', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      textAlign: TextAlign.right,
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: '未设置',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: (v) => setState(() { _url = v; }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 灰色
                  const Text('历史记录', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  // 红色
                  IconButton(onPressed: () {}, icon: Icon(Icons.delete_outline, color: Colors.red))
                ],
              ),
            ),
            // 历史记录列表
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final url = _history[index];
                  return Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _url = url;
                                _controller.text = _url;
                              });
                            },
                            child: Text(url, style: const TextStyle(fontSize: 14)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _history.removeAt(index);
                            });
                            _saveHistory();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
