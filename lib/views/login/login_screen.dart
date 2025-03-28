import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:axalta/blocs/auth/auth_bloc.dart';
import 'package:axalta/exceptions/form_exceptions.dart';
import 'bloc/login_bloc.dart';
import 'package:axalta/constants/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  void submitForm(BuildContext context) {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final data = _formKey.currentState?.value;
      context.read<LoginBloc>().add(
            LoginRequestEvent(
              email: data!['userName'],
              password: data['password'],
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return BlocProvider(
          create: (context) => LoginBloc(),
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginSuccessState) {
                context.read<AuthBloc>().add(
                      AuthAuthenticateEvent(state.user),
                    );
                Navigator.of(context).pushNamedAndRemoveUntil(
                  homeRoute,
                  (route) => false,
                );
              }
            },
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text("Giriş"),
                ),
                body: Builder(
                  builder: (_) {
                    return Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: FormBuilder(
                            key: _formKey,
                            child: Builder(builder: (context) {
                              if (state is LoginErrorState) {
                                if (state.exception is FormFieldsException) {
                                  for (var error in (state.exception
                                          as FormFieldsException)
                                      .errors
                                      .entries) {
                                    _formKey.currentState?.invalidateField(
                                      name: error.key,
                                      errorText: error.toString(),
                                    );
                                    return AlertDialog(
                                      title: const Text("Hatalı Giriş"),
                                      content: const Text(
                                          'Kullanıcı Adı veya Şifre hatalı'),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            // Dialog kapatılıyor
                                            Navigator.of(context)
                                                .pushNamedAndRemoveUntil(
                                                    loginRoute,
                                                    (route) => false);
                                          },
                                          child: const Text('Tamam'),
                                        ),
                                      ],
                                    );
                                  }
                                }
                              }

                              return Column(
                                children: [
                                  Builder(builder: (context) {
                                    return Container();
                                  }),
                                  FormBuilderTextField(
                                    name: 'userName',
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Kullanıcı Adı',
                                    ),
                                    textInputAction: TextInputAction.next,
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                    ]),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  FormBuilderTextField(
                                    name: 'password',
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Şifre',
                                    ),
                                    obscureText: true,
                                    textInputAction: TextInputAction.done,
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                    ]),
                                    onSubmitted: (_) {
                                      if (state is! AuthLoadingState) {
                                        submitForm(context);
                                      }
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  MaterialButton(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    onPressed: () {
                                      if (state is! LoginLoadingState) {
                                        submitForm(context);
                                      }
                                    },
                                    child: (state is LoginLoadingState)
                                        ? const Center(
                                            child: SizedBox(
                                              height: 15,
                                              width: 15,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                        : const SizedBox(
                                            width: double.infinity,
                                            child: Text(
                                              'Giriş',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
