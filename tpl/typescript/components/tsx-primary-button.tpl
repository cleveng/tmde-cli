import { Plus } from 'lucide-vue-next'
import { NButton, NIcon } from 'naive-ui'
import { computed, defineComponent } from 'vue'

import { use<@ data.capitalize_name @> } from './<@ data.name @>-provider'

export default defineComponent({
  name: '<@ data.capitalize_name @>PrimaryButton',
  props: {},
  setup() {
    const { setOpen } = use<@ data.capitalize_name @>()

    return () => (
      <>
        <NButton onClick={() => setOpen('add')}>
          {{
            icon: () => (
              <NIcon>
                <Plus />
              </NIcon>
            ),
            default: () => '添 加'
          }}
        </NButton>
      </>
    )
  }
})
