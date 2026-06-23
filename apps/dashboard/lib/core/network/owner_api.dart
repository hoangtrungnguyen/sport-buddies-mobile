import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared auth plumbing for the owner backend (Django) API clients.

/// The signed-in owner's Supabase access token — the Bearer credential every
/// backend call forwards. Null when there is no active session.
String? ownerAccessToken() =>
    Supabase.instance.client.auth.currentSession?.accessToken;

/// Authorization header map for [token], ready to spread into a request's
/// headers. Empty when [token] is null/blank, so an unauthenticated call sends
/// no Authorization header.
Map<String, dynamic> bearerHeader(String? token) => <String, dynamic>{
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
