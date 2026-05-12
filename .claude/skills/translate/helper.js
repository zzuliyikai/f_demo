/**
 * NexOptim 翻译管理辅助脚本
 */

// 支持的语言
const LANGUAGES = {
  zh_hans: { name: '中文简体', file: 'zh_hans_strings.dart', flag: '🇨🇳' },
  en: { name: '英语', file: 'en_strings.dart', flag: '🇬🇧' },
  de: { name: '德语', file: 'de_strings.dart', flag: '🇩🇪' },
  fr: { name: '法语', file: 'fr_strings.dart', flag: '🇫🇷' },
  ja: { name: '日语', file: 'ja_strings.dart', flag: '🇯🇵' },
};

// 常用术语翻译
const COMMON = {
  '设备': { en: 'Device', de: 'Gerät', fr: 'Appareil', ja: 'デバイス' },
  '列表': { en: 'List', de: 'Liste', fr: 'Liste', ja: 'リスト' },
  '设置': { en: 'Settings', de: 'Einstellungen', fr: 'Paramètres', ja: '設定' },
  '保存': { en: 'Save', de: 'Speichern', fr: 'Enregistrer', ja: '保存' },
  '取消': { en: 'Cancel', de: 'Abbrechen', fr: 'Annuler', ja: 'キャンセル' },
  '删除': { en: 'Delete', de: 'Löschen', fr: 'Supprimer', ja: '削除' },
  '编辑': { en: 'Edit', de: 'Bearbeiten', fr: 'Modifier', ja: '編集' },
  '详情': { en: 'Details', de: 'Details', fr: 'Détails', ja: '詳細' },
};

// 翻译文件路径
const LOCALIZATION_PATH = 'lib/localization';

console.log('NexOptim 翻译管理工具');
console.log('支持语言:', Object.values(LANGUAGES).map(l => l.flag + l.name).join(' '));
