import { defineComponent, inject, provide, ref, type Ref } from 'vue'

import { type API } from '/#/api'

type <@ data.capitalize_name @>DialogType = 'add' | 'edit' | 'delete' | null

type <@ data.capitalize_name @>ContextType = {
  open: Ref<<@ data.capitalize_name @>DialogType | null>
  setOpen: (type: <@ data.capitalize_name @>DialogType) => void
  currentRow: Ref<API.Account | null>
  setCurrentRow: (row: API.Account | null) => void
}

export default defineComponent({
  name: '<@ data.capitalize_name @>Provider',
  props: {},
  setup(_, { slots }) {
    // Dialog state
    const open = ref<<@ data.capitalize_name @>DialogType | null>(null)
    const setOpen = (type: <@ data.capitalize_name @>DialogType) => {
      open.value = type
    }

    // Current row state
    const currentRow = ref<API.Account | null>(null)
    const setCurrentRow = (row: API.Account | null) => {
      currentRow.value = row
    }

    // Provide context
    const <@ data.capitalize_name @>Context: <@ data.capitalize_name @>ContextType = {
      open,
      setOpen,
      currentRow,
      setCurrentRow
    }

    provide('<@ data.capitalize_name @>Context', <@ data.capitalize_name @>Context)

    return () => slots.default?.()
  }
})

/**
 * Returns the context of the alarms provider.
 * The context includes the state of the dialogs and the current row.
 * It must be used within the <<@ data.capitalize_name @>Provider> component.
 * @returns {<@ data.capitalize_name @>ContextType}
 */
export const use<@ data.capitalize_name @> = () => {
  const context = inject<<@ data.capitalize_name @>ContextType>('<@ data.capitalize_name @>Context')
  if (!context) {
    throw new Error('use<@ data.capitalize_name @> must be used within <<@ data.capitalize_name @>Provider>')
  }

  return context
}
