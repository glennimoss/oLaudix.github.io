@Util = {}

_Units = ["", "K", "M", "B", "T"]
_BigUnitStart = "a".charCodeAt(0)
_WayTooBigUnit = "z".charCodeAt(0)

# Use en-US so locale doesn't affect logic.
_ToStr = Intl.NumberFormat("en-US", {useGrouping: false, maximumFractionDigits: 0})
_PrettyFmt = Intl.NumberFormat(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2})
@Util.formatTTNumber = (number) ->
  num = number
  # We're converting to a string because Math.log10 can't be trusted
  # e.g. Math.log10(1e15) = 14.999999999999998
  exp = (_ToStr.format(num).length - 1) // 3
  if exp == 0
    if num % 1
      return _PrettyFmt.format(num)
    if isNaN(num) or num == Infinity
      return "--"
    return num.toString()
  if exp < _Units.length
    unit = _Units[exp]
  else
    unitCode = _BigUnitStart + exp - _Units.length
    unit = String.fromCharCode(unitCode, unitCode)
    if unitCode > _WayTooBigUnit
      unit = "e" + (exp*3)
  num = num / 1000**exp
  return _PrettyFmt.format(num) + unit

_PctFmt = Intl.NumberFormat(undefined, {style: "percent"})

@Util.formatPercent = (num) ->
  (if num > 0 then '+' else '') + _PctFmt.format(num)

_First = 33
_Base = 94

@Util.encode = (num, digits=2) ->
  chars = []
  while digits
    chars.unshift(String.fromCharCode((num % _Base) + _First))
    num = num // _Base
    --digits

  return chars.join('')

@Util.decode = (str, digits=2) ->
  num = 0
  for i in [0...Math.min(digits, str.length)]
    num *= _Base
    num += str.charCodeAt(i) - _First

  return num


_.mixin
  sum: (iter) ->
    _.reduce(iter, ((n, m) -> n + m), 0)
