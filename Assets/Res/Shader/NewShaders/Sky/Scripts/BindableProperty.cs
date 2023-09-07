using System;
using UnityEngine;

namespace Renderering.Sky
{
    public class BindableProperty<T>
    {
        private T mValue = default(T);
        private Action<T> onValueChanged;

        public T Value
        {
            get => mValue;
            set
            {
                if (mValue == null)
                {
                    mValue = value;
                    onValueChanged?.Invoke(value);
                }
                else if (!value.Equals(mValue))
                {
                    mValue = value;
                    onValueChanged?.Invoke(value);
                }
            }
        }

        public void RegisterOnValueChanged(Action<T> onValueChanged)
        {
            this.onValueChanged += onValueChanged;
        }

        public void UnRegisterOnValueChanged(Action<T> onValueChanged)
        {
            this.onValueChanged -= onValueChanged;
        }
    }
}