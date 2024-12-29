import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class QuranSearchScreen extends StatefulWidget {
  @override
  _QuranSearchScreenState createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends State<QuranSearchScreen> {
  final TextEditingController _keywordController = TextEditingController();
  String? _selectedSurahNumber = 'all';
  List<dynamic> _surahs = [];
  List<dynamic> _searchResults = [];
  Map<int, String> _tafsirResults = {};
  Set<int> _expandedAyahs = {};
  int _resultCount = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    final jsonString = await rootBundle.loadString('assets/surahs.json');
    final data = json.decode(jsonString);
    setState(() {
      _surahs = data;
    });
  }

  Future<void> _searchQuran() async {
    final keyword = _keywordController.text.trim();
    final surah = _selectedSurahNumber ?? 'all';
    final url =
        'http://api.alquran.cloud/v1/search/$keyword/$surah/quran-simple-clean';

    if (keyword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال كلمة البحث')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _resultCount = data['data']['count'];
          _searchResults = (data['data']['matches'] as List<dynamic>).toList();
        });
      } else {
        setState(() {
          _resultCount = 0;
        });
      }
    } catch (e) {
      setState(() {
        _resultCount = 0;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchTafseer(int ayahNumber) async {
    final tafsirUrl =
        'http://api.alquran.cloud/v1/ayah/$ayahNumber/ar.muyassar';

    try {
      final response = await http.get(Uri.parse(tafsirUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tafsir = data['data']['text'];

        setState(() {
          _tafsirResults[ayahNumber] = tafsir;
          _expandedAyahs.add(ayahNumber);
        });
        // print(_tafsirResults);
        // print("**********************************");
        // print(_expandedAyahs);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ في تحميل التفسير')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('القرآن الكريم'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Keyword Search Field
              TextField(
                controller: _keywordController,
                decoration: InputDecoration(
                  labelText: 'كلمة البحث',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onSubmitted: (_) => _searchQuran(),
              ),
              const SizedBox(height: 16),
              // Dropdown for Surah Selection
              DropdownButtonFormField<String>(
                value: _selectedSurahNumber,
                items: [
                  const DropdownMenuItem(
                    value: 'all',
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'القرآن كاملا',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  ..._surahs.map((surah) {
                    return DropdownMenuItem<String>(
                      value: surah['number'].toString(),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Ensure compact layout
                          children: [
                            Text(
                              '${surah['name']} (${surah['number']})',
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.book, color: Colors.teal),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSurahNumber = value;
                  });
                  _searchQuran(); // Automatically run the search
                },
                decoration: InputDecoration(
                  labelText: 'السورة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Search Button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _searchQuran,
                      child: const Text('بحث'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_resultCount == 0 &&
                  !_isLoading &&
                  _searchResults.isNotEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sentiment_dissatisfied,
                          color: Colors.grey,
                          size: 50,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'لا توجد نتائج مطابقة',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                  if (_resultCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        'عدد النتائج: $_resultCount',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        final ayahNumber = result['number'];
                        final isExpanded = _expandedAyahs.contains(ayahNumber);
                        final tafsir = _tafsirResults[ayahNumber] ?? '';
                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ayah Text
                                Text(
                                  '${result['surah']['name']} - آية ${result['numberInSurah']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  result['text'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    height: 1.5,
                                    fontFamily: 'Amiri',
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                                const SizedBox(height: 10),
                                // Tafseer Button
                                ElevatedButton(
                                  onPressed: () {
                                    if (isExpanded) {
                                      print("Will remove tafseer");
                                      print(_expandedAyahs);
                                      setState(() {
                                        _expandedAyahs.remove(ayahNumber);
                                      });
                                      print(_expandedAyahs);
                                      print("tafseer has been removed");

                                    } else {
                                      _fetchTafseer(ayahNumber);
                                    }
                                  },
                                  child: Text(isExpanded
                                      ? 'إخفاء التفسير'
                                      : 'عرض التفسير'),
                                ),
                                // Tafseer Text
                                if (isExpanded && tafsir.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'التفسير الميسر:',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          tafsir,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            height: 1.5,
                                            color: Colors.black87,
                                          ),
                                          textAlign: TextAlign.justify,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
