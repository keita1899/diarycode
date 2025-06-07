// フラッシュメッセージの管理クラス
class FlashMessages {
  constructor() {
    this.init()
  }

  init() {
    // DOMが読み込まれた後に実行
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () =>
        this.setupFlashMessages(),
      )
    } else {
      this.setupFlashMessages()
    }

    // Turboでページが変更された際にも実行
    document.addEventListener('turbo:load', () => this.setupFlashMessages())
  }

  setupFlashMessages() {
    this.setupCloseButtons()
    this.setupAutoDismiss()
  }

  // 閉じるボタンのイベントリスナーを設定
  setupCloseButtons() {
    const closeButtons = document.querySelectorAll('.flash-close')

    closeButtons.forEach((button) => {
      // 既存のイベントリスナーを削除（重複防止）
      button.removeEventListener('click', this.handleCloseClick)
      // 新しいイベントリスナーを追加
      button.addEventListener('click', this.handleCloseClick.bind(this))
    })
  }

  // 閉じるボタンクリック時の処理
  handleCloseClick(event) {
    event.preventDefault()
    const button = event.currentTarget
    const flashMessage = button.closest('.flash-message')

    if (flashMessage) {
      this.dismissMessage(flashMessage)
    }
  }

  // 自動閉じ機能を設定
  setupAutoDismiss() {
    const messagesWithAutoDismiss = document.querySelectorAll(
      '.flash-message[data-auto-dismiss]',
    )

    messagesWithAutoDismiss.forEach((message) => {
      // 既にタイマーが設定されている場合はスキップ
      if (message.dataset.timerSet === 'true') {
        return
      }

      const delay = parseInt(message.dataset.autoDismiss)

      if (delay && delay > 0) {
        // タイマー設定済みのマークを付ける
        message.dataset.timerSet = 'true'

        setTimeout(() => {
          if (document.body.contains(message)) {
            this.dismissMessage(message)
          }
        }, delay)
      }
    })
  }

  // メッセージを閉じる共通処理
  dismissMessage(messageElement) {
    if (!messageElement) return

    // アニメーション開始
    messageElement.style.opacity = '0'
    messageElement.style.transform = 'translateY(-10px)'

    // アニメーション完了後に要素を削除
    setTimeout(() => {
      if (document.body.contains(messageElement)) {
        messageElement.remove()
      }
    }, 300)
  }

  // プログラムから手動でメッセージを追加する場合
  static addMessage(type, message, autoDismiss = 5000) {
    const container =
      document.querySelector('.flash-messages-container') ||
      document.querySelector('body')

    if (!container) return

    const messageElement = this.createMessageElement(type, message, autoDismiss)
    container.insertAdjacentHTML('afterbegin', messageElement)

    // 新しく追加されたメッセージに対してもイベントを設定
    const flashManager = new FlashMessages()
    flashManager.setupFlashMessages()
  }

  // メッセージ要素のHTMLを生成
  static createMessageElement(type, message, autoDismiss) {
    const config = this.getMessageConfig(type)

    return `
      <div class="mb-4 p-4 rounded-md ${config.bgClass} border flash-message" data-auto-dismiss="${autoDismiss}">
        <div class="flex justify-between">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 ${config.iconClass}" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="${config.iconPath}" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <p class="text-sm ${config.textClass}">${message}</p>
            </div>
          </div>
          <div class="ml-4 flex-shrink-0 flex">
            <button type="button" class="flash-close ${config.buttonClass} rounded-md inline-flex focus:outline-none focus:ring-2 focus:ring-offset-2">
              <span class="sr-only">閉じる</span>
              <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </button>
          </div>
        </div>
      </div>
    `
  }

  // メッセージタイプごとの設定
  static getMessageConfig(type) {
    const configs = {
      notice: {
        bgClass: 'bg-green-50 border-green-200',
        textClass: 'text-green-600',
        iconClass: 'text-green-400',
        buttonClass:
          'bg-green-50 text-green-400 hover:text-green-500 focus:ring-offset-green-50 focus:ring-green-600',
        iconPath:
          'M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z',
      },
      success: {
        bgClass: 'bg-green-50 border-green-200',
        textClass: 'text-green-600',
        iconClass: 'text-green-400',
        buttonClass:
          'bg-green-50 text-green-400 hover:text-green-500 focus:ring-offset-green-50 focus:ring-green-600',
        iconPath:
          'M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z',
      },
      alert: {
        bgClass: 'bg-red-50 border-red-200',
        textClass: 'text-red-600',
        iconClass: 'text-red-400',
        buttonClass:
          'bg-red-50 text-red-400 hover:text-red-500 focus:ring-offset-red-50 focus:ring-red-600',
        iconPath:
          'M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z',
      },
      warning: {
        bgClass: 'bg-yellow-50 border-yellow-200',
        textClass: 'text-yellow-600',
        iconClass: 'text-yellow-400',
        buttonClass:
          'bg-yellow-50 text-yellow-400 hover:text-yellow-500 focus:ring-offset-yellow-50 focus:ring-yellow-600',
        iconPath:
          'M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z',
      },
      info: {
        bgClass: 'bg-blue-50 border-blue-200',
        textClass: 'text-blue-600',
        iconClass: 'text-blue-400',
        buttonClass:
          'bg-blue-50 text-blue-400 hover:text-blue-500 focus:ring-offset-blue-50 focus:ring-blue-600',
        iconPath:
          'M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z',
      },
    }

    return configs[type] || configs.info
  }
}

// フラッシュメッセージマネージャーのインスタンスを作成
const flashMessagesManager = new FlashMessages()

// グローバルに利用可能にする
window.FlashMessages = FlashMessages
