import 'package:amaris_test/core/domain/errors/portfolio_failure.dart';
import 'package:amaris_test/core/domain/models/fund.dart';
import 'package:amaris_test/core/domain/models/transaction_record.dart';
import 'package:amaris_test/features/portfolio/state/portfolio_notifier.dart';
import 'package:amaris_test/i18n/strings.g.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_dialog_form_provider.g.dart';

class SubscriptionDialogFormState {
  const SubscriptionDialogFormState({
    required this.amountInput,
    required this.selectedNotification,
    required this.inlineErrorMessage,
  });

  factory SubscriptionDialogFormState.initial(
    NotificationMethod initialNotificationMethod,
  ) {
    return SubscriptionDialogFormState(
      amountInput: '',
      selectedNotification: initialNotificationMethod,
      inlineErrorMessage: null,
    );
  }

  final String amountInput;
  final NotificationMethod selectedNotification;
  final String? inlineErrorMessage;

  SubscriptionDialogFormState copyWith({
    String? amountInput,
    NotificationMethod? selectedNotification,
    String? inlineErrorMessage,
    bool clearInlineErrorMessage = false,
  }) {
    return SubscriptionDialogFormState(
      amountInput: amountInput ?? this.amountInput,
      selectedNotification: selectedNotification ?? this.selectedNotification,
      inlineErrorMessage: clearInlineErrorMessage
          ? null
          : inlineErrorMessage ?? this.inlineErrorMessage,
    );
  }
}

@riverpod
class SubscriptionDialogForm extends _$SubscriptionDialogForm {
  @override
  SubscriptionDialogFormState build({
    required NotificationMethod initialNotificationMethod,
  }) {
    return SubscriptionDialogFormState.initial(initialNotificationMethod);
  }

  void setAmountInput(String value) {
    state = state.copyWith(amountInput: value);
  }

  void setNotificationMethod(NotificationMethod method) {
    state = state.copyWith(selectedNotification: method);
  }

  Future<bool> confirmSubscription({required Fund fund}) async {
    final amount = int.tryParse(state.amountInput.trim());
    if (amount == null || amount <= 0) {
      state = state.copyWith(
        inlineErrorMessage: t.funds.subscriptionDialog.invalidAmount,
      );
      return false;
    }

    state = state.copyWith(clearInlineErrorMessage: true);

    await ref
        .read(portfolioAsyncNotifierProvider.notifier)
        .subscribe(
          fund: fund,
          amountCop: amount,
          notificationMethod: state.selectedNotification,
        );

    final portfolioState = ref.read(portfolioAsyncNotifierProvider);
    if (!portfolioState.hasError) {
      return true;
    }

    final error = portfolioState.error;
    final message = switch (error) {
      final PortfolioFailure e => e.friendlyMessage,
      final Object e when e is Exception => e.toString().replaceFirst(
        'Exception: ',
        '',
      ),
      _ => t.funds.subscriptionDialog.submissionFailed,
    };

    state = state.copyWith(inlineErrorMessage: message);
    return false;
  }
}
