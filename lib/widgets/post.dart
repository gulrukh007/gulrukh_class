import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gulrukh_class/models/user.dart';
import 'package:gulrukh_class/pages/home.dart';
import 'package:gulrukh_class/widgets/custom_image.dart';
import 'package:gulrukh_class/widgets/progress.dart';

class Post extends StatefulWidget {
  final String? postId;
  final String? ownerId;
  final String? username;
  final String? location;
  final String? description;
  final String? mediaUrl;
  final dynamic likes;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    print("post id ${doc['postId']}");
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId ?? "",
        ownerId: this.ownerId ?? "",
        username: this.username ?? "",
        location: this.location ?? "",
        description: this.description ?? "",
        mediaUrl: this.mediaUrl ?? "",
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String? currentUserId = currentUser?.id ?? "";
  final String? postId;
  final String? ownerId;
  final String? username;
  final String? location;
  final String? description;
  final String? mediaUrl;
  int likeCount;
  Map? likes;
  bool isLiked = false;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.likeCount = 0,
  });

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User1 user = User1.fromDocument(snapshot.data!);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl ?? ""),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => print('showing profile'),
            child: Text(
              user.username ?? "",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location ?? ""),
          trailing: IconButton(
            onPressed: () => print('deleting post'),
            icon: Icon(Icons.more_vert),
          ),
        );
      },
    );
  }

  handleLikePost() {
    bool _isLiked = likes?[currentUserId] == true;

    if (_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes?[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes?[currentUserId] = true;
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl ?? ""),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => print('showing comments'),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$username ",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: Text(description ?? ""))
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes?[currentUserId] == true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter()
      ],
    );
  }
}
