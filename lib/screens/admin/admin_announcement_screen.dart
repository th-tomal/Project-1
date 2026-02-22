import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AdminAnnouncementScreen extends StatefulWidget {
  const AdminAnnouncementScreen({super.key});

  @override
  State<AdminAnnouncementScreen> createState() =>
      _AdminAnnouncementScreenState();
}

class _AdminAnnouncementScreenState
    extends State<AdminAnnouncementScreen> {

  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  String target = "all";
  bool loading = false;

  Future<void> publishAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection("announcements")
        .add({
      "title": titleController.text.trim(),
      "message": messageController.text.trim(),
      "target": target,
      "createdBy": FirebaseAuth.instance.currentUser!.uid,
      "createdAt": FieldValue.serverTimestamp(),
    });

    titleController.clear();
    messageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Announcement Published")),
    );

    setState(() => loading = false);
  }

  Future<void> deleteAnnouncement(String docId) async {
    await FirebaseFirestore.instance
        .collection("announcements")
        .doc(docId)
        .delete();
  }

  Future<void> updateAnnouncement(
      String docId,
      String newTitle,
      String newMessage,
      String newTarget,
      ) async {
    await FirebaseFirestore.instance
        .collection("announcements")
        .doc(docId)
        .update({
      "title": newTitle,
      "message": newMessage,
      "target": newTarget,
    });
  }

  void showEditDialog(
      String docId,
      Map<String, dynamic> data,
      ) {
    final editTitle = TextEditingController(text: data["title"]);
    final editMessage = TextEditingController(text: data["message"]);
    String editTarget = data["target"];

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Edit Announcement"),
          content: SingleChildScrollView(
            child: Column(
              children: [

                TextField(
                  controller: editTitle,
                  decoration:
                  const InputDecoration(labelText: "Title"),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: editMessage,
                  maxLines: 3,
                  decoration:
                  const InputDecoration(labelText: "Message"),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: editTarget,
                  items: const [
                    DropdownMenuItem(
                        value: "all", child: Text("All")),
                    DropdownMenuItem(
                        value: "student",
                        child: Text("Students")),
                    DropdownMenuItem(
                        value: "teacher",
                        child: Text("Teachers")),
                  ],
                  onChanged: (value) {
                    editTarget = value!;
                  },
                  decoration:
                  const InputDecoration(labelText: "Target"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await updateAnnouncement(
                  docId,
                  editTitle.text.trim(),
                  editMessage.text.trim(),
                  editTarget,
                );
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Announcements"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// 🔹 CREATE FORM
            Form(
              key: _formKey,
              child: Column(
                children: [

                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? "Enter title" : null,
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: messageController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Message",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? "Enter message" : null,
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: target,
                    decoration: const InputDecoration(
                      labelText: "Send To",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: "all", child: Text("All")),
                      DropdownMenuItem(
                          value: "student",
                          child: Text("Students Only")),
                      DropdownMenuItem(
                          value: "teacher",
                          child: Text("Teachers Only")),
                    ],
                    onChanged: (value) {
                      setState(() => target = value!);
                    },
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                      loading ? null : publishAnnouncement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      child: loading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text("Publish Announcement"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            const Divider(),

            const SizedBox(height: 20),

            /// 🔹 LIST OF ANNOUNCEMENTS
            const Text(
              "Published Announcements",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("announcements")
                  .orderBy("createdAt",
                  descending: true)
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Text("No announcements yet.");
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {

                    final doc = docs[index];
                    final data =
                    doc.data() as Map<String, dynamic>;

                    Timestamp? timestamp =
                    data["createdAt"];
                    String date = "";

                    if (timestamp != null) {
                      date = DateFormat(
                          "dd MMM yyyy • hh:mm a")
                          .format(
                          timestamp.toDate());
                    }

                    return Card(
                      margin: const EdgeInsets.only(
                          bottom: 15),
                      child: Padding(
                        padding:
                        const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [

                            Text(
                              data["title"],
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight
                                    .bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(
                                height: 5),

                            Text(
                              data["message"],
                            ),

                            const SizedBox(
                                height: 5),

                            Text(
                              "Target: ${data["target"]}",
                              style: const TextStyle(
                                  fontSize: 12,
                                  color:
                                  Colors.grey),
                            ),

                            Text(
                              date,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color:
                                  Colors.grey),
                            ),

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .end,
                              children: [

                                IconButton(
                                  icon: const Icon(
                                      Icons.edit,
                                      color: Colors
                                          .blue),
                                  onPressed: () =>
                                      showEditDialog(
                                          doc.id,
                                          data),
                                ),

                                IconButton(
                                  icon: const Icon(
                                      Icons.delete,
                                      color: Colors
                                          .red),
                                  onPressed: () async {

                                    final confirm =
                                    await showDialog<
                                        bool>(
                                      context:
                                      context,
                                      builder:
                                          (_) =>
                                          AlertDialog(
                                            title:
                                            const Text(
                                                "Delete?"),
                                            content:
                                            const Text(
                                                "Are you sure?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context,
                                                        false),
                                                child:
                                                const Text(
                                                    "Cancel"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context,
                                                        true),
                                                child:
                                                const Text(
                                                    "Delete"),
                                              ),
                                            ],
                                          ),
                                    );

                                    if (confirm ==
                                        true) {
                                      deleteAnnouncement(
                                          doc.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
