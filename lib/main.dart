import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';


Future<void>main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
// void main() {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const firebase(),
    );
  }
}

class firebase extends StatefulWidget {
  const firebase({super.key});

  @override
  State<firebase> createState() => _firebaseState();
}

class _firebaseState extends State<firebase> {

List<LiveScore>_listLiveScore=[];
final FirebaseFirestore db=FirebaseFirestore.instance;
// Future<void>_getLiveScore()async{
//   _listLiveScore.clear();
//   final QuerySnapshot<Map<String, dynamic>> snapshot =await db.collection('football').get();
//   for(QueryDocumentSnapshot<Map<String,dynamic>> doc in snapshot.docs){
//     LiveScore liveScore = LiveScore(
//         id: doc.id,
//         team1Name: doc.get('team1'),
//         team2Name: doc.get('team2'),
//         team1Score: doc.get('team1_score'),
//         team2Score: doc.get('team2_score'),
//         matchRunning: doc.get('is_running'),
//         winner: doc.get('winner'),
//       );
//     _listLiveScore.add(liveScore);
//     }
//   setState(() { });
// }


// @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _getLiveScore();
//   }
//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text("Firebase Demo class"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: db.collection('football').snapshots(),
        builder: (context,  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>snapshots){
          if(snapshots.connectionState==ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }
          if(snapshots.hasError){
            return Center(child: Text("Error from ${snapshots.error.toString()}"));
          }

          if (snapshots.hasData) {
            _listLiveScore.clear();
            for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshots.data!.docs) {
              LiveScore liveScore = LiveScore(id: doc.id,
                  team1Name: doc.get('team1'),
                  team2Name: doc.get('team2'),
                  team1Score: doc.get('team1_score'),
                  team2Score: doc.get("team2_score"),
                  matchRunning: doc.get("is_running"),
                  winner: doc.get("winner"));
              _listLiveScore.add(liveScore);
            }
          }

          {
            return ListView.builder(
                itemCount: _listLiveScore.length,
                itemBuilder: (context, index) {
                  LiveScore liveScore = _listLiveScore[index];
                  return ListTile(
                    onLongPress: (){
                      db.collection('football').doc(liveScore.id).delete();
                    },
                    leading: CircleAvatar(
                      radius: 8,
                      backgroundColor: liveScore.matchRunning ? Colors.green : Colors.white,
                    ),
                    title: Text(liveScore.id),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(liveScore.team1Name),
                            Text(" vs "),
                            Text(liveScore.team2Name)
                          ],
                        ),
                        Text("Match is running : ${liveScore.matchRunning}"),
                        Text("Winner is : ${liveScore.winner}")
                      ],
                    ),
                    trailing: Text(
                        "${liveScore.team1Score} : ${liveScore.team2Score}",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                  );
                });
          }
        }
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: () async {
          LiveScore liveScore = LiveScore(
              id: "Ban vs In",
              team1Name: "Bangladesh",
              team2Name: "India",
              team1Score: 3,
              team2Score: 0,
              matchRunning: false,
              winner:"Bangladesh",
          );
          await db.collection('football').doc(liveScore.id).set(liveScore.toMap());
        },
        child: Icon(Icons.add,),
      ),
    );
  }
}

class LiveScore {
  final String id;
  final String team1Name;
  final String team2Name;
  final int team1Score;
  final int team2Score;
  final bool matchRunning;
  final String winner;

  LiveScore({
    required this.id,
    required this.team1Name,
    required this.team2Name,
    required this.team1Score,
    required this.team2Score,
    required this.matchRunning,
    required this.winner,
  });

  Map<String, dynamic> toMap() {
    return {
      'team1': team1Name,
      'team2': team2Name,
      'team1_score': team1Score,
      'team2_score': team2Score,
      "is_running": matchRunning,
      'winner':winner,
    };
  }
}
