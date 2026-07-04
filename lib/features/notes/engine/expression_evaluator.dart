/// A tiny hand-written BODMAS expression evaluator for Kuber Notes inline
/// arithmetic (the `=` inline mode). Recursive-descent parser — no `eval`, no
/// `dart:mirrors`, no packages.
///
/// Supported: `+ - * /`, parentheses, integers, decimals, negative numbers,
/// comma-grouped numbers (`1,000`), and a `₹` prefix (treated as the number).
/// NOT supported: exponents, variables, functions, percentages.
///
/// Returns null on any invalid expression (unbalanced parens, trailing
/// operator, empty, division by zero) so the caller can fall back gracefully.
library;

class ExpressionEvaluator {
  const ExpressionEvaluator();

  double? evaluate(String input) {
    try {
      final parser = _Parser(input);
      final value = parser._parseExpression();
      parser._skipWhitespace();
      if (!parser._atEnd) return null; // trailing junk
      if (value.isNaN || value.isInfinite) return null;
      return value;
    } on _EvalError {
      return null;
    }
  }
}

class _EvalError implements Exception {}

class _Parser {
  final String s;
  int _pos = 0;

  _Parser(this.s);

  bool get _atEnd => _pos >= s.length;

  void _skipWhitespace() {
    while (!_atEnd && s[_pos] == ' ') {
      _pos++;
    }
  }

  String? _peek() {
    _skipWhitespace();
    return _atEnd ? null : s[_pos];
  }

  // expression := term (('+' | '-') term)*
  double _parseExpression() {
    var value = _parseTerm();
    while (true) {
      final op = _peek();
      if (op == '+') {
        _pos++;
        value += _parseTerm();
      } else if (op == '-') {
        _pos++;
        value -= _parseTerm();
      } else {
        break;
      }
    }
    return value;
  }

  // term := factor (('*' | '/') factor)*
  double _parseTerm() {
    var value = _parseFactor();
    while (true) {
      final op = _peek();
      if (op == '*') {
        _pos++;
        value *= _parseFactor();
      } else if (op == '/') {
        _pos++;
        final divisor = _parseFactor();
        if (divisor == 0) throw _EvalError();
        value /= divisor;
      } else {
        break;
      }
    }
    return value;
  }

  // factor := ('+' | '-')? ( '(' expression ')' | number )
  double _parseFactor() {
    final sign = _peek();
    if (sign == '+') {
      _pos++;
      return _parseFactor();
    }
    if (sign == '-') {
      _pos++;
      return -_parseFactor();
    }
    if (sign == '(') {
      _pos++;
      final value = _parseExpression();
      if (_peek() != ')') throw _EvalError();
      _pos++;
      return value;
    }
    return _parseNumber();
  }

  double _parseNumber() {
    _skipWhitespace();
    if (!_atEnd && s[_pos] == '₹') _pos++; // optional ₹ prefix
    final start = _pos;
    while (!_atEnd) {
      final c = s[_pos];
      final isDigit = c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39;
      if (isDigit || c == '.' || c == ',') {
        _pos++;
      } else {
        break;
      }
    }
    if (_pos == start) throw _EvalError();
    final raw = s.substring(start, _pos).replaceAll(',', '');
    final value = double.tryParse(raw);
    if (value == null) throw _EvalError();
    return value;
  }
}
