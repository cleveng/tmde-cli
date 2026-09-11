import { defineComponent } from 'vue'

import <@ data.capitalize_name @>ActionDialog from './<@ data.name @>-action-dialog'
import <@ data.capitalize_name @>MutateDialog from './<@ data.name @>-mutate-dialog'
import { use<@ data.capitalize_name @> } from './<@ data.name @>-provider'

import { type API } from '/#/api'

export default defineComponent({
  name: '<@ data.capitalize_name @>Dialogs',
  props: {},
  setup() {
    const { open, setOpen, currentRow, setCurrentRow } = use<@ data.capitalize_name @>()

    return () => (
      <>
        <<@ data.capitalize_name @>ActionDialog
          key='<@ data.name @>-create'
          open={open.value === 'add'}
          onOpenChange={() => setOpen(null)}
        />
        {currentRow && (
          <<@ data.capitalize_name @>MutateDialog
            key={`<@ data.name @>-update-${currentRow.value?.id}`}
            open={open.value === 'edit'}
            onOpenChange={() => {
              setOpen(null)
              setTimeout(() => {
                setCurrentRow(null)
              }, 500)
            }}
            currentRow={currentRow.value as API.<@ data.pascal_case_name @>}
          />
        )}
      </>
    )
  }
})
