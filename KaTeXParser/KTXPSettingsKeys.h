//
//  KTXPSettingsKeys.h
//  KaTeXParser
//
//  Created by Alice Roldán on 6/23/24.
//

#ifndef KTXPSettingsKeys_h
#define KTXPSettingsKeys_h

typedef NSString * KTXPSettingsKey;
const KTXPSettingsKey DisplayModeKey = @"DisplayMode";
//const KTXPSettingsKey OutputKey = @"Output";
const KTXPSettingsKey LeqNoKey = @"LeqNo";
const KTXPSettingsKey FleQnKey = @"FleQn";
/// Throw an exception once an error is encountered.
const KTXPSettingsKey ThrowOnErrorKey = @"ThrowOnError";
/// Set error color. (UNUSED)
const KTXPSettingsKey ErrorColorKey = @"ErrorColor";
const KTXPSettingsKey MacrosKey = @"Macros";
const KTXPSettingsKey MinRuleThicknessKey = @"MinRuleThickness";
/// Treat color macros as text color macros.
const KTXPSettingsKey ColorIsTextColorKey = @"ColorIsTextColor";
/// Do strict macro parsing.
const KTXPSettingsKey StrictKey = @"Strict";
const KTXPSettingsKey TrustKey = @"Trust";
const KTXPSettingsKey MaxSizeKey = @"MaxSize";
const KTXPSettingsKey MaxExpandKey = @"MaxExpand";
const KTXPSettingsKey GlobalGroupKey = @"GlobalGroup";
/// Automatically add double slashing to escape normal strings.
const KTXPSettingsKey FixEscapeSlashesKey = @"FixEscapeSlashes";

#endif /* KTXPSettingsKeys_h */
