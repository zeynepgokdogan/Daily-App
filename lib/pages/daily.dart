import 'package:flutter/material.dart';
import '/util/styles.dart';
import '/util/calendar.dart';

class Daily extends StatefulWidget {
  const Daily({super.key});

  @override
  State<Daily> createState() => _DailyState();
}

class _DailyState extends State<Daily> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/1.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Center(
              child: Text(
                'Add Memories',
                style: customTextStyle,
                textAlign: TextAlign.left,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: const SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Calendar()),
                SizedBox(height: 30),
                TextField(
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: hintTextStyle,
                    hintText: 'Title',
                  ),
                  style: customTextStyle,
                ),
                SizedBox(height: 16),
                TextField(
                  textAlign: TextAlign.left,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: customTextStyle,
                    hintText: 'Start typing...',
                  ),
                  style: customTextStyle,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80.0, right: 15.0),
            child: Container(
              width: 120,
              height: 50,
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Color(0xFFF26950),
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.add_photo_alternate_outlined,
                        color: iconStyle().color,
                        size: iconStyle().size,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.save_alt_outlined,
                        color: iconStyle().color,
                        size: iconStyle().size,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
