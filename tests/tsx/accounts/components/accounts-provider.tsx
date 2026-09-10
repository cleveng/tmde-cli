import { defineComponent, inject, provide, ref, type Ref } from 'vue'

import { type API } from '/#/api'

type AccountsDialogType = 'add' | 'edit' | 'delete' | null

type AccountsContextType = {
  open: Ref<AccountsDialogType | null>
  setOpen: (type: AccountsDialogType) => void
  currentRow: Ref<API.Account | null>
  setCurrentRow: (row: API.Account | null) => void
}

export default defineComponent({
  name: 'AccountsProvider',
  props: {},
  setup(_, { slots }) {
    // Dialog state
    const open = ref<AccountsDialogType | null>(null)
    const setOpen = (type: AccountsDialogType) => {
      open.value = type
    }

    // Current row state
    const currentRow = ref<API.Account | null>(null)
    const setCurrentRow = (row: API.Account | null) => {
      currentRow.value = row
    }

    // Provide context
    const AccountsContext: AccountsContextType = {
      open,
      setOpen,
      currentRow,
      setCurrentRow
    }

    provide('AccountsContext', AccountsContext)

    return () => slots.default?.()
  }
})

/**
 * Returns the context of the alarms provider.
 * The context includes the state of the dialogs and the current row.
 * It must be used within the <AccountsProvider> component.
 * @returns {AccountsContextType}
 */
export const useAccounts = () => {
  const context = inject<AccountsContextType>('AccountsContext')
  if (!context) {
    throw new Error('useAccounts must be used within <AccountsProvider>')
  }

  return context
}
