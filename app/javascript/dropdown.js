// Header dropdown functionality
let dropdownController = null

export function initDropdown() {
  // 既存のイベントリスナーをクリーンアップ
  if (dropdownController) {
    dropdownController.abort()
  }

  const dropdown = document.querySelector('[data-dropdown]')
  if (!dropdown) return

  const toggle = dropdown.querySelector('[data-dropdown-toggle]')
  const menu = dropdown.querySelector('[data-dropdown-menu]')

  if (!toggle || !menu) return

  // 新しいAbortControllerを作成
  dropdownController = new AbortController()
  const { signal } = dropdownController

  // トグルボタンクリック
  toggle.addEventListener(
    'click',
    function (e) {
      e.preventDefault()
      e.stopPropagation()
      menu.classList.toggle('hidden')
    },
    { signal },
  )

  // メニュー外クリックで閉じる
  document.addEventListener(
    'click',
    function (e) {
      if (!dropdown.contains(e.target)) {
        menu.classList.add('hidden')
      }
    },
    { signal },
  )

  // ESCキーで閉じる
  document.addEventListener(
    'keydown',
    function (e) {
      if (e.key === 'Escape') {
        menu.classList.add('hidden')
      }
    },
    { signal },
  )
}

// DOM読み込み完了時とTurbo画面遷移時に初期化
document.addEventListener('DOMContentLoaded', initDropdown)
document.addEventListener('turbo:load', initDropdown)
