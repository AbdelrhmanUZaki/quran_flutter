import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('عن التطبيق'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'عن التطبيق',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'تطبيق القرآن الكريم يتيح لك البحث في آيات القرآن الكريم والإطلاع على تفسيرها بطريقة سهلة وميسرة.',
                style: TextStyle(fontSize: 18, height: 1.5),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 30),
              Text(
                'عن المطور',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'أنا عبدالرحمن زكي، مطور تطبيقات متخصص في تطوير تطبيقات إسلامية تساهم في خدمة المسلمين.',
                style: TextStyle(fontSize: 18, height: 1.5),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
