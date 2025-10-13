import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shape_mobile/models/AwardModel.dart';
import 'package:shape_mobile/db/app_database.dart';

class AwardListWidget extends StatefulWidget {
  const AwardListWidget({super.key});

  @override
  State<AwardListWidget> createState() => _AwardListWidgetState();
}

class _AwardListWidgetState extends State<AwardListWidget> {
  List<Award> _awards = [];

  @override
  void initState() {
    super.initState();
    _loadAwards();
  }

  Future<void> _loadAwards() async {
    final awards = await AppDatabase.instance.fetchAllAwards();

    setState(() {
      _awards = awards;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_awards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(
          'Awards',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _awards.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final award = _awards[index];
              return Container(
                width: 120,
                decoration: BoxDecoration(
                  color: Color(0x66D6DBED),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Image.file(
                        File(award.path),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                    Text(
                      award.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
