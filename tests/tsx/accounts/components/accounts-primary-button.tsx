import { Plus } from 'lucide-vue-next'
import { NButton, NIcon } from 'naive-ui'
import { defineComponent } from 'vue'

import { useAccounts } from './accounts-provider'

export default defineComponent({
  name: 'AccountsPrimaryButton',
  props: {},
  setup() {
    const { setOpen } = useAccounts()

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
