import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/friend_request_cubit.dart';
import '../auth/services/auth_service.dart';
import '../auth/services/friend_request_service.dart';
import '../main_screens/home_screen/cut_loose/auth/cut_loose_cubit.dart';
import '../main_screens/home_screen/cut_loose/auth/firebase_service.dart';
import '../main_screens/home_screen/note/auth/note_cubit.dart';
import '../main_screens/home_screen/note/auth/note_service.dart';
import '../main_screens/home_screen/public_chat/cubit/stream_chat_cubit.dart';
import '../main_screens/home_screen/public_chat/cubit/stream_chat_service.dart';
import '../main_screens/home_screen/quiz/cubit/question_cubit.dart';
import '../main_screens/home_screen/quiz/cubit/quiz_cubit.dart';
import '../main_screens/home_screen/quiz/services/hint_service.dart';
import '../main_screens/home_screen/quiz/services/question_service.dart';
import '../main_screens/home_screen/quiz/services/quiz_service.dart';
import '../main_screens/home_screen/quiz/services/timer_service.dart';
import '../main_screens/profile/security/cubit/phone_auth_service.dart';
import '../main_screens/profile/security/cubit/phone_number_cubit.dart';
import '../main_screens/profile/security/cubit/two_factor_auth_cubit.dart';
import '../main_screens/profile/security/cubit/two_factor_auth_service.dart';
import '../main_screens/profile/security/password/cubit/password_management_cubit.dart';
import '../main_screens/profile/security/password/services/password_management_service.dart';

MultiBlocProvider appBlocProviders(
    StreamChatClient client, AuthService authService, Widget child) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => AuthCubit(AuthService(), client),
      ),
      BlocProvider(
        create: (context) => FriendRequestCubit(
          FriendRequestService(),
        ),
      ),
      BlocProvider(
        create: (context) => PhoneNumberCubit(
          PhoneAuthService(),
        ),
      ),
      BlocProvider(
        create: (context) => NoteCubit(
          NoteService(),
        ),
      ),
      BlocProvider(
        create: (context) => CutLooseCubit(
          FirebaseService(),
        ),
      ),
      BlocProvider(
        create: (context) => QuizCubit(
          quizService: QuizService(),
        ),
      ),
      BlocProvider(
          create: (context) => QuestionCubit(
                questionService: QuestionService(),
                hintService: HintService(),
                timerService: TimerService(),
              )),
      BlocProvider(
        create: (context) => TwoFactorAuthCubit(
          TwoFactorAuthService(),
        ),
      ),
      BlocProvider(
        create: (context) => PasswordManagementCubit(
          PasswordManagementService(),
        ),
      ),
      BlocProvider(
        create: (context) => StreamChatCubit(
          StreamChatService(client),
          authService,
        ),
      )
    ],
    child: child,
  );
}
