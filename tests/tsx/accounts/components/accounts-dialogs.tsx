import { defineComponent } from 'vue'

import AccountsActionDialog from './accounts-action-dialog'
import AccountsMutateDialog from './accounts-mutate-dialog'
import { useAccounts } from './accounts-provider'

import { type API } from '/#/api'

export default defineComponent({
  name: 'AccountsDialogs',
  props: {},
  setup() {
    const { open, setOpen, currentRow, setCurrentRow } = useAccounts()

    return () => (
      <>
        <AccountsActionDialog
          key='accounts-create'
          open={open.value === 'add'}
          onOpenChange={() => setOpen(null)}
        />
        {currentRow && (
          <AccountsMutateDialog
            key={`accounts-update-${currentRow.value?.id}`}
            open={open.value === 'edit'}
            onOpenChange={() => {
              setOpen(null)
              setTimeout(() => {
                setCurrentRow(null)
              }, 500)
            }}
            currentRow={currentRow.value as API.Accounts}
          />
        )}
      </>
    )
  }
})
