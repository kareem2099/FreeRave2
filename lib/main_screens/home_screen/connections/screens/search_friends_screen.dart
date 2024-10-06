import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/cubit/friend_request_cubit.dart';
import '../models/user_model.dart';
import '../Widgets/debouncer.dart';
import '../../../../auth/cubit/auth_state.dart';

class SearchFriendsScreen extends StatefulWidget {
  const SearchFriendsScreen({super.key});

  @override
  State<SearchFriendsScreen> createState() => _SearchFriendsScreenState();
}

class _SearchFriendsScreenState extends State<SearchFriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 300);
  List<UserModel> _results = [];
  bool _noResults = false;
  String _errorMessage = '';

  final Map<String, bool> _pendingRequests = {};
  String? currentUserUid;

  @override
  void initState() {
    super.initState();
    // Get the current user's UID
    currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Friends'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: BlocBuilder<FriendRequestCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const PreferredSize(
                  preferredSize: Size.fromHeight(4.0),
                  child: LinearProgressIndicator(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 16.0),
            Expanded(
              child: _buildResultsView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'Search by name or ID',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: _clearSearch,
        ),
      ),
      onChanged: (value) => _debouncer.run(() => _searchForFriends(value)),
    );
  }

  Widget _buildResultsView() {
    return BlocBuilder<FriendRequestCubit, AuthState>(
      builder: (context, state) {
        if (_errorMessage.isNotEmpty) {
          return Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)));
        }
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AuthError) {
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
        }
        if (state is FriendRequestSearchSuccess) {
          _results = state.friends;
          _noResults = _results.isEmpty;
          if (_noResults) {
            return const Center(child: Text('No users found.'));
          }
          return _buildResultsList();
        }
        return const Center(child: Text('Start typing to search for users.'));
      },
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final user = _results[index];
        return UserListItem(
          user: user,
          isPending: _pendingRequests[user.uid] ?? false,
          onFriendRequestSent: () => _sendFriendRequest(user.uid),
        );
      },
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _results.clear();
      _errorMessage = '';
      _noResults = false;
      _pendingRequests.clear();
    });
  }

  void _searchForFriends(String query) async {
    if (query.isEmpty) {
      _clearSearch();
      return;
    }

    setState(() {
      _errorMessage = '';  // Clear any previous errors
    });

    try {
      context.read<FriendRequestCubit>().searchFriends(currentUserUid!, query); // Replace with actual user ID
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching users: ${e.toString()}';
      });
    }
  }


  void _sendFriendRequest(String friendId) {
    context.read<FriendRequestCubit>().sendFriendRequest(currentUserUid!, friendId); // Replace with real user ID
    setState(() {
      _pendingRequests[friendId] = true; // Update pending request status
    });
  }
}

class UserListItem extends StatelessWidget {
  final UserModel user;
  final bool isPending;
  final VoidCallback onFriendRequestSent;

  const UserListItem({
    required this.user,
    required this.isPending,
    required this.onFriendRequestSent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.photoUrl),
          onBackgroundImageError: (_, __) => const Icon(Icons.person),
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(user.email),
        trailing: IconButton(
          icon: isPending
              ? const Icon(Icons.hourglass_empty, color: Colors.grey)
              : const Icon(Icons.person_add, color: Colors.green),
          onPressed: isPending ? null : onFriendRequestSent,
        ),
      ),
    );
  }
}
