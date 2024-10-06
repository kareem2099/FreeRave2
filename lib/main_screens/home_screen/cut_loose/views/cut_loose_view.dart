import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/cut_loose_cubit.dart';
import '../auth/cut_loose_state.dart';


class CutLooseView extends StatelessWidget {
  const CutLooseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cut Loose Area')),
      body: BlocBuilder<CutLooseCubit, CutLooseState>(
        builder: (context, state) {
          if (state is CutLooseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CutLooseLoaded) {
            return ListView.builder(
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(state.messages[index]));
              },
            );
          } else if (state is CutLooseError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Press the button to load messages'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddMessageDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMessageDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Message'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter your message'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<CutLooseCubit>().addMessage(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
