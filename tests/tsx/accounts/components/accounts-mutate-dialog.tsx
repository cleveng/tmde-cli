import { useMutation } from '@urql/vue'
import {
  type FormInst,
  NForm,
  NFormItem,
  NInput,
  NModal,
  NSelect,
  NSpace,
  NButton,
  useMessage
} from 'naive-ui'
import { type SelectMixedOption } from 'naive-ui/es/select/src/interface'
import { defineComponent, inject, reactive, type Ref, ref } from 'vue'

import { type AccountsInput, UpdateAccountsDocument } from '@/generated/graphql'
import { type API } from '/#/api'
import { extractErrorMessage } from '@/plugins'

export default defineComponent({
  name: 'AccountsMutateDialog',
  props: {
    open: {
      type: Boolean,
      required: true
    },
    onOpenChange: {
      type: Function as PropType<(open: boolean) => void>,
      required: true
    },
    currentRow: {
      type: Object as PropType<API.Accounts>,
      required: true
    }
  },
  setup(props) {
    const message = useMessage()

    const refetch = inject<() => void>('refetch')

    const todo = inject<Ref<string[]>>('todo')

    const defaultParams = () => ({
      id: props.currentRow?.id,
      name: props.currentRow?.name,
    })

    const state = reactive({
      params: defaultParams(),
      loading: false
    })

    const rules = reactive({
      name: [
        {
          required: true,
          message: '请输入名称',
          trigger: 'blur'
        }
      ],
    })

    const close = () => {
      state.loading = false
      state.params = defaultParams()
      props.onOpenChange(false)
    }

    const { executeMutation: mutation, fetching } = useMutation(UpdateAccountsDocument)

    const formRef = ref<FormInst | null>(null)
    const onSubmit = async () => {
      formRef?.value?.validate(async (errors: any) => {
        if (errors) {
          message.error("请填写表单")
          return
        }

        if (state.loading) return
        state.loading = true

        const params: AccountsInput = {
          ..state.params
        }

        try {
          const res = await mutation({ id: props.currentRow.id, input: params })
          if (res.error) {
            const title = extractErrorMessage(res.error)
            message.error(title)
            return
          }

          if (res.data?.updateAccounts) {
            message.success("提交成功")
            refetch?.()
            close()
          }
        } catch (error) {
          console.log(error)
        } finally {
          state.loading = false
        }
      })
    }

    return () => (
      <NModal
        preset='dialog'
        title="表单占位标题"
        class='max-h-160 w-full overflow-y-auto sm:w-11/12 md:max-w-(--breakpoint-lg)'
        show={props.open}
        show-icon={false}
        onClose={close}
        onMaskClick={close}
      >
        {{
          default: () => (
            <>
              <p class='mb-5 text-gray-400'>表单占位标题</p>
              <NForm
                ref={formRef}
                class='space-y-1'
                label-placement='top'
                model={state.params}
                rules={rules}
              >
                <NFormItem label='名 称' path='name'>
                  {{
                    default: () => (
                      <>
                        <NInput
                          value={state.params.name}
                          onUpdateValue={(val: string) => (state.params.name = val)}
                          size='large'
                        />
                      </>
                    ),
                    feedback: () => (
                      <span class='text-gray-400'>备注：xxxx</span>
                    )
                  }}
                </NFormItem>
                <NFormItem label='平台类型' path='platform_type'>
                  <NSelect
                    value={state.params.platform_type}
                    onUpdateValue={(val: number) => (state.params.platform_type = val)}
                    size='large'
                    label-field='name'
                    value-field='id'
                    options={todo?.value as SelectMixedOption[]}
                  />
                </NFormItem>
              </NForm>
            </>
          ),
          action: () => (
            <NSpace justify='end'>
              <NButton
                disabled={fetching.value}
                loading={fetching.value}
                onClick={close}
              >
                取 消
              </NButton>
              <NButton
                disabled={fetching.value}
                loading={fetching.value}
                onClick={onSubmit}
              >
                保 存
              </NButton>
            </NSpace>
          )
        }}
      </NModal>
    )
  }
})
