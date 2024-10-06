import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/password_management_cubit.dart';
import '../cubit/password_management_state.dart';

class PasswordHistoryScreen extends StatelessWidget {
  const PasswordHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Password History")),
      body: BlocBuilder<PasswordManagementCubit, PasswordManagementState>(
        builder: (context, state) {
          if (state is PasswordManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PasswordHistoryLoaded) {
            return ListView.builder(
              itemCount: state.history.length,
              itemBuilder: (context, index) {
                final passwordEntry = state.history[index];
                return ListTile(
                  title: Text(passwordEntry.password),
                  subtitle: Text("Changed on: ${passwordEntry.changeDate}"),
                  trailing: Icon(
                    Icons.security,
                    color: passwordEntry.strength > 0.5 ? Colors.green : Colors.red,
                  ),
                );
              },
            );
          } else if (state is PasswordManagementError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text("No password history available"));
        },
      ),
    );
  }
}
