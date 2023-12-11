String? nullCheckString(
  dynamic data,
) {
  return data as String?;
}

int nullCheckInt(
  dynamic data,
) {
  if (data == null) {
    return 0;
  } else {
    return data as int;
  }
}
